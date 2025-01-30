# Define paths
$zipPath = "$env:TEMP\scripts.zip"
$installPath = "$env:ProgramFiles\righty"  # Specify your installation directory
$configFile = "$installPath\scripts\config.json"  # Path to the JSON config file

Write-Host "Downloading release archive..."
Invoke-WebRequest -Uri "https://github.com/just-hms/righty/releases/latest/download/scripts.zip" -OutFile $zipPath

Write-Host "Creating installation directory..."
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Write-Host "Extracting files..."
Expand-Archive -Path $zipPath -DestinationPath $installPath -Force

Write-Host "Reading configuration file..."

# Load JSON configuration
$configContent = Get-Content -Path $configFile -Raw
$cfg = $configContent | ConvertFrom-Json

Write-Host "Creating context menu entries for each script..."

# Process each script based on the JSON config
foreach ($scriptCfg in $cfg) {
    $name = $scriptCfg.name
    $files = $scriptCfg.files
    $title = $scriptCfg.title

    # Split the file extensions by comma and trim spaces
    $extensions = $files | ForEach-Object { $_.Trim() }

    Write-Host "----"
    Write-Host $name
    Write-Host $files
    Write-Host $title
    Write-Host "----"
    continue

    # Find the script file
    $scriptPath = Join-Path $installPath $name
    if (-not (Test-Path $scriptPath)) {
        Write-Warning "Script '$name' not found at '$scriptPath'. Skipping context menu entry."
        continue
    }

    foreach ($ext in $extensions) {
        # Register the script with the context menu for each file extension
        $key = "HKCU:\Software\Classes\$ext\shell\OpenWith$title"
        New-Item -Path $key -Force | Out-Null
        New-ItemProperty -Path $key -Name "Icon" -Value "powershell.exe" -Force | Out-Null
        New-Item -Path "$key\command" -Force | Out-Null
        Set-ItemProperty -Path "$key\command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`"" | Out-Null
        Write-Host "Added context menu entry for '$title' ($name) for extension '$ext'"
    }
}

Write-Host "Installation complete!"
