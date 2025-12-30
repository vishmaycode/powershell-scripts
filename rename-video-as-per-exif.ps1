$exiftool = "exiftool.exe"

Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(mp4|mov|mkv|avi|webm)$'
} | ForEach-Object {

    $json = & $exiftool -j `
        -CreateDate `
        -MediaCreateDate `
        -TrackCreateDate `
        -ModifyDate `
        -FileModifyDate `
        "$($_.FullName)" | ConvertFrom-Json

    # Priority order (videos are messy, this works best in practice):
    # 1. MediaCreateDate (actual recording time)
    # 2. TrackCreateDate (fallback for MP4/MOV)
    # 3. CreateDate (container metadata)
    # 4. EXIF ModifyDate
    # 5. Filesystem modified date (Explorer)
    if ($json.MediaCreateDate) {
        $rawDate = $json.MediaCreateDate
    }
    elseif ($json.TrackCreateDate) {
        $rawDate = $json.TrackCreateDate
    }
    elseif ($json.CreateDate) {
        $rawDate = $json.CreateDate
    }
    elseif ($json.ModifyDate) {
        $rawDate = $json.ModifyDate
    }
    elseif ($json.FileModifyDate) {
        $rawDate = $json.FileModifyDate
    }
    else {
        $rawDate = $null
    }

    if ($rawDate) {
        # Normalize "YYYY:MM:DD HH:MM:SS" → filename-safe
        $safeDate = $rawDate.Replace(":", "_").Replace(" ", "-")

        $baseName = "video-$safeDate"
        $ext = $_.Extension.ToLower()

        $newName = "$baseName$ext"
        $newPath = Join-Path $_.DirectoryName $newName

        $count = 1
        while (Test-Path $newPath) {
            $newName = "$baseName-$count$ext"
            $newPath = Join-Path $_.DirectoryName $newName
            $count++
        }

        Rename-Item $_.FullName $newPath
        Write-Host "Renamed: $($_.Name) → $newName"
    }
    else {
        Write-Host "No usable date found, skipped: $($_.Name)"
    }
}
