param (
    [string]$path = ""
)

if (-not $path) {
    Write-Host "Error: No file path provided."
    exit 1
}

$path = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location -PSProvider FileSystem).ProviderPath, $path))

if (-not (Test-Path $path)) {
    Write-Host "Error: File '$path' does not exist."
    exit 1
}

if ([System.IO.Path]::GetExtension($path) -ne ".dwg") {
    Write-Host "Error: File is not a .dwg file."
    exit 1
}

$DraftSightApp = New-Object -ComObject "DraftSight.Application"
$DraftSightApp.Visible = $false

if ($null -eq $DraftSightApp){
    Write-Host "Error attaching to DraftSight"
    exit 1
}

try {
    $doc = $DraftSightApp.OpenDocument($path, 1)
    $xrefs = $doc.GetExternalReferences()

    $clip = ""
    foreach ($xref in $xrefs) {
        $clip += $xref.Name() + "`r`n"
    }

    if (-not $clip) {
        Write-Host "No external references found."
        exit 1
    }

    Set-Clipboard -Value $clip
    Write-Host "External references copied to clipboard."

} catch {
    Write-Host "Error: Unable to extract external references."
    Write-Host "Exception Message: $_"
    Write-Host "Exception Details: $($_.Exception)"
    exit 1
}
