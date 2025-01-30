# Define paths
$zipPath = "$env:TEMP\righty.zip"
$installPath = "$env:ProgramFiles\righty"
$scriptsPath = "$env:ProgramFiles\righty\scripts"
$configFile = "$installPath\config.json"

Invoke-WebRequest -Uri "https://github.com/just-hms/righty/releases/latest/download/righty.zip" -OutFile $zipPath

New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Expand-Archive -Path $zipPath -DestinationPath $installPath -Force

# Load JSON configuration
$configContent = Get-Content -Path $configFile -Raw
$cfg = $configContent | ConvertFrom-Json

# Process each script based on the JSON config
foreach ($scriptCfg in $cfg) {
    $name = $scriptCfg.name
    $extensions = $scriptCfg.extensions
    $title = $scriptCfg.title

    # Find the script file
    $scriptPath = Join-Path $scriptsPath $name
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
    }
}
