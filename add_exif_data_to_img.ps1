$exiftool = "exiftool.exe"

# Format: YYYY:MM:DD HH:MM:SS
$forcedDate = "2018:02:03 00:00:00"

Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(jpg|jpeg|png|heic)$'
} | ForEach-Object {

    & $exiftool `
        "-DateTimeOriginal=$forcedDate" `
        "-CreateDate=$forcedDate" `
        "-ModifyDate=$forcedDate" `
        "-FileCreateDate=$forcedDate" `
        "-FileModifyDate=$forcedDate" `
        -overwrite_original `
        "$($_.FullName)"

    Write-Host "Forced date on: $($_.Name)"
}
