# Define paths
$installPath = "$env:ProgramFiles\righty"  # The installation directory
$configFile = "$installPath\config.ini"  # Path to the .ini config file

Write-Host "Uninstalling..."

# Read the configuration file
if (-Not (Test-Path $configFile)) {
    Write-Warning "Config file not found. Skipping uninstallation of context menu entries."
    return
}

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
$iniConfig = Get-IniContent -path $configFile

Write-Host "Removing context menu entries for each script..."

# Process each script based on the config
foreach ($section in $iniConfig.Keys) {
    $name = $iniConfig[$section]["name"]
    $files = $iniConfig[$section]["files"]
    $title = $iniConfig[$section]["title"]

    # Split the file extensions by comma and trim spaces
    $extensions = $files.Split(',') | ForEach-Object { $_.Trim() }

    # Remove the context menu entry for each file extension
    foreach ($ext in $extensions) {
        $key = "HKCU:\Software\Classes\$ext\shell\Open with $title"
        if (Test-Path $key) {
            Remove-Item -Path $key -Recurse -Force
            Write-Host "Removed context menu entry for '$title' ($name) for extension '$ext'"
        } else {
            Write-Warning "No context menu entry found for '$title' ($name) for extension '$ext'"
        }
    }
}

Write-Host "Removing extracted files..."

# Remove the installation folder and its contents
if (Test-Path $installPath) {
    Remove-Item -Path $installPath -Recurse -Force
    Write-Host "Uninstalled the scripts and removed the installation directory."
} else {
    Write-Warning "Installation directory not found. Nothing to uninstall."
}

Write-Host "Uninstallation complete!"
