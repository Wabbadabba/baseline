Clear-Host

$path = "C:\"
$filter = "*.txt"
$output = "C:\testing.csv"

[System.Collections.ArrayList]$directory = @()
Get-ChildItem -Path $path -Filter $filter -Recurse -ErrorAction SilentlyContinue| % {
    [void]$directory.Add($_)
    Write-Progress -Activity "Searching for files in $path" -Status $_.Directory -CurrentOperation ("Files Collected: {0:N0}" -f $directory.Count) -PercentComplete -1
}

Write-Progress -Activity "Parsing out File Names"
$name = @($directory.Name)

Write-Progress -Activity "Parsing out File Paths"
$fullName = @($directory.Fullname)

Write-Progress -Activity "Getting MD5 Hashes of Files"
$md5hash = @(($directory | Get-FileHash -Algorithm MD5).hash)

Write-Progress -Activity "Getting SHA1 Hashes of Files"
$sha1hash = @(($directory | Get-FileHash -Algorithm SHA1).hash)

Write-Progress -Activity "Getting SHA256 Hashes of Files"
$sha256hash = @(($directory | Get-FileHash -Algorithm SHA256).hash)


If ($name.Count -gt ($fullName.Count -or 
                     $md5hash.Count -or
                     $sha1hash.Count -or
                     $sha256hash.Count)) {
    $limit = $name.Count
} Elseif ($fullName.Count -gt ($name.Count -or 
                               $md5hash.Count -or
                               $sha1hash.Count -or
                               $sha256hash.Count)) {
    $limit = $fullName.Count
} Elseif ($md5hash.Count -gt ($name.Count -or 
                               $fullName.Count -or
                               $sha1hash.Count -or
                               $sha256hash.Count)) {
    $limit = $md5hash.Count
} Elseif ($sha1hash.Count -gt ($name.Count -or 
                               $fullName.Count -or
                               $md5hash.Count -or
                               $sha256hash.Count)) {
    $limit = $sha1hash.Count
} Elseif ($sha256hash.Count -gt ($name.Count -or 
                               $fullName.Count -or
                               $md5hash.Count -or
                               $sha1hash.Count)) {
    $limit = $sha256hash.Count
}


Write-Progress -Activity "Parsing File data to an organized structure"
$csv = For ($i = 0; $i -lt $limit; $i++) {
    New-Object -TypeName psobject -Property @{
        'Path' = $(If ($fullName[$i]) { $fullName[$i] })
        'File Name' = $(If ($name[$i]) { $name[$i] })
        'MD5 Hash' = $(If ($md5hash[$i]) { $md5hash[$i] })
        'SHA1 Hash' = $(If ($sha1hash[$i]) { $sha1hash[$i] })
        'SHA256 Hash' = $(If ($sha256hash[$i]) { $sha256hash[$i] })
        
    }
}

Write-Host "Exporting Product to $output"
$csv | Select-Object -Property "File Name", "Path", "MD5 Hash", "SHA1 Hash", "SHA256 Hash" |Export-Csv $output -NoTypeInformation
