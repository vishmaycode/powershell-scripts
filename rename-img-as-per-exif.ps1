$exiftool = "exiftool.exe"

Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(heic|jpg|jpeg|png)$'
} | ForEach-Object {

    $json = & $exiftool -j `
        -DateTimeOriginal `
        -CreateDate `
        -ModifyDate `
        -FileModifyDate `
        "$($_.FullName)" | ConvertFrom-Json

    # Priority order:
    # 1. Camera date
    # 2. EXIF create date
    # 3. EXIF modify date
    # 4. FILESYSTEM modified date (Windows Explorer)
    if ($json.DateTimeOriginal) {
        $rawDate = $json.DateTimeOriginal
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
        # Normalize to filename-safe format
        $safeDate = $rawDate.Replace(":", "_").Replace(" ", "-")

        $baseName = "image-$safeDate"
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
