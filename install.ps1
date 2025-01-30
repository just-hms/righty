# Define paths
$zipPath = "$env:TEMP\scripts.zip"
$installPath = "$env:ProgramFiles\righty"  # Specify your installation directory
$configFile = "$installPath\config.ini"  # Path to the .ini config file

Write-Host "Downloading release archive..."
Invoke-WebRequest -Uri "https://github.com/just-hms/righty/releases/latest/download/scripts.zip" -OutFile $zipPath

Write-Host "Creating installation directory..."
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Write-Host "Extracting files..."
Expand-Archive -Path $zipPath -DestinationPath $installPath -Force

Write-Host "Reading configuration file..."

# Load .NET ConfigurationManager to read INI
Add-Type -AssemblyName System.Configuration

function LoadINI {
    param(
        [string]$path
    )
    $iniConfig = @{}
    $ini = [System.Configuration.ConfigurationManager]::OpenMappedExeConfiguration(
        (New-Object System.Configuration.ExeConfigurationFileMap), [System.Configuration.ConfigurationUserLevel]::None)
    $iniFile = $ini.GetSection("settings")

    foreach ($section in $iniFile) {
        $sectionName = $section.SectionInformation.Name
        $iniConfig[$sectionName] = @{}

        foreach ($key in $section.ElementInformation.Properties) {
            $iniConfig[$sectionName][$key.Name] = $key.Value
        }
    }
    return $iniConfig
}

# Parse INI configuration
$iniConfig = LoadINI -path $configFile

Write-Host "Creating context menu entries for each script..."

# Process each script based on the config
foreach ($section in $iniConfig.Keys) {
    $name = $iniConfig[$section]["name"]
    $files = $iniConfig[$section]["files"]
    $title = $iniConfig[$section]["title"]

    # Split the file extensions by comma and trim spaces
    $extensions = $files.Split(',') | ForEach-Object { $_.Trim() }

    # Find the script file
    $scriptPath = Join-Path $installPath $name
    if (Test-Path $scriptPath) {
        foreach ($ext in $extensions) {
            # Register the script with the context menu for each file extension
            $key = "HKCU:\Software\Classes\$ext\shell\Open with $title"
            New-Item -Path $key -Force | Out-Null
            New-ItemProperty -Path $key -Name "Icon" -Value "powershell.exe" -Force | Out-Null
            New-Item -Path "$key\command" -Force | Out-Null
            Set-ItemProperty -Path "$key\command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`"" | Out-Null

            Write-Host "Added context menu entry for '$title' ($name) for extension '$ext'"
        }
    }
    else {
        Write-Warning "Script '$name' not found at '$scriptPath'. Skipping context menu entry."
    }
}

Write-Host "Installation complete!"
