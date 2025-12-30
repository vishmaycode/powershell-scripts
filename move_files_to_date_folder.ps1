$year  = "2025"
$month = "11"

$folderName = "$year-$month"

# Create folder if it doesn't exist
if (-not (Test-Path $folderName)) {
    New-Item -ItemType Directory -Name $folderName | Out-Null
}

# Move matching files
Get-ChildItem -File -Filter "image-$year`_$month`_*" | ForEach-Object {
    Move-Item $_.FullName -Destination $folderName
    Write-Host "Moved: $($_.Name)"
}
