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
    Write-Host "Error: The file is not a .dwg file."
    exit 1
}

Write-Host "Opening DraftSight... This may take a moment."

$DraftSightApp = New-Object -ComObject "DraftSight.Application"
$DraftSightApp.Visible = $false

if ($null -eq $DraftSightApp) {
    Write-Host "Error: Unable to attach to DraftSight."
    exit 1
}

Write-Host "Opening the document..."

try {
    $doc = $DraftSightApp.OpenDocument($path, 1)
    $xrefs = $doc.GetExternalReferences()

    $clip = ""
    foreach ($xref in $xrefs) {
        $clip += $xref.Name() + "`r`n"
    }

    Set-Clipboard -Value $clip
    Write-Host "External references copied to clipboard."

} catch {
    Write-Host "Error: Unable to extract external references."
    Write-Host "Exception Message: $_"
    Write-Host "Exception Details: $($_.Exception)"
    exit 1
}
