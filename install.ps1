# Define paths
$zipPath = "$env:TEMP\righty.zip"
$installPath = "$env:ProgramFiles\righty"

if (Test-Path $installPath) {
    Remove-Item -Path $installPath -Recurse -Force
}

Invoke-WebRequest -Uri "https://github.com/just-hms/righty/releases/latest/download/righty.zip" -OutFile $zipPath
New-Item -ItemType Directory -Path $installPath -Force | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $installPath -Force
