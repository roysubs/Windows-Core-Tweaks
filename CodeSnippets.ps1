# capture the stuff you want here as array
$info = foreach ($zip in $zipfiles) { 
    # output whatever you need to be collected in $info
    $zip.Name
    # construct the folderpath for the unzipped files
    $dst = Join-Path -Path $zip.DirectoryName -ChildPath $zip.BaseName
    if (!(Test-Path $dst -PathType Container)) {
        $null = New-Item -ItemType Directory $dst -ErrorAction SilentlyContinue
        $null = Expand-Archive -LiteralPath $zip.FullName -DestinationPath $dst -ErrorAction SilentlyContinue
    }
}

# now you can create a multiline string from the $info array
$result = $info -join "`r`n==========`r`n"
