$exiftool = "exiftool.exe"

# Format: YYYY:MM:DD HH:MM:SS
$forcedDate = "2018:02:03 00:00:00"

Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(mp4|mov|m4v|avi|mkv|webm)$'
} | ForEach-Object {

    & $exiftool `
        "-AllDates=$forcedDate" `
        "-CreateDate=$forcedDate" `
        "-ModifyDate=$forcedDate" `
        "-TrackCreateDate=$forcedDate" `
        "-TrackModifyDate=$forcedDate" `
        "-MediaCreateDate=$forcedDate" `
        "-MediaModifyDate=$forcedDate" `
        "-FileCreateDate=$forcedDate" `
        "-FileModifyDate=$forcedDate" `
        -overwrite_original `
        "$($_.FullName)"

    Write-Host "Forced date on: $($_.Name)"
}
