# Define paths
$zipPath = "$env:TEMP\righty.zip"
$installPath = "$env:ProgramFiles\righty"
$scriptsPath = "$installPath\scripts"
$configFile = "$installPath\config.json"
$regFile = "$env:TEMP\righty.reg"

Invoke-WebRequest -Uri "https://github.com/just-hms/righty/releases/latest/download/righty.zip" -OutFile $zipPath

New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Expand-Archive -Path $zipPath -DestinationPath $installPath -Force

# Load JSON configuration
$configContent = Get-Content -Path $configFile -Raw
$cfg = $configContent | ConvertFrom-Json

# Initialize registry file content
$regContent = "Windows Registry Editor Version 5.00`r`n`r`n"

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
        $extKey = "HKEY_CLASSES_ROOT\.$ext\shell\$title"
        $commandKey = "$extKey\command"
        $command = "powershell -ExecutionPolicy Bypass -File `"$scriptPath`" `"%1`""
        
        $regContent += "[$extKey]`r`n"
        $regContent += "@=`"$title`"`r`n`r`n"
        $regContent += "[$commandKey]`r`n"
        $regContent += "@=`"$command`"`r`n`r`n"
    }
}

# Save registry file
$regContent | Set-Content -Path $regFile -Encoding ASCII

Write-Output "Registry file generated: $regFile"
