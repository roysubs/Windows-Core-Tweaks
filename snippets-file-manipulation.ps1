# This file is for useful code snippets. i.e. we never want this script to run like this,
# so just put "exit" on the first line to quit if it is ever run accidentally:
exit

# Extract each zipfile to its own folder using Expand-Archive
$zipfiles = ls C:\Downloads\*.zip       # Capture the zip files to extract as an array
$info = foreach ($zip in $zipfiles) {   # $info will contain the output of the foreach loop as it extracts the zip files
    $zip.Name                           # This is an output and will be collected into $info, to show later if required
    $dst = Join-Path -Path $zip.DirectoryName -ChildPath $zip.BaseName   # Construct the folderpath for the unzipped files
    if (!(Test-Path $dst -PathType Container)) {
        $null = New-Item -ItemType Directory $dst -ErrorAction SilentlyContinue   # Use "$null =" instead of "| $null" as the pipeline has overhead
        $null = Expand-Archive -LiteralPath $zip.FullName -DestinationPath $dst -ErrorAction SilentlyContinue
    }
}
$result = $info -join "`r`n==========`r`n"   # Can now create a multiline string from the $info array, and output $result if required

# Basic Compress-Archive syntax
Compress-Archive -Path D:\path\to\file.txt -DestinationPath D:\path\to\archive.zip



# Get all lines from $filepath (possibly a log file) that matches a date string ($yesterday)
$yesterday = '{0:yyyy-MM-dd}' -f (Get-Date).AddDays(-1)
$out = Join-Path -Path ([System.IO.Path]::GetDirectoryName($filepath)) -ChildPath ("log_{0}.log" -f $yesterday)
# use SimpleMatch because the pattern is to be taken literally (no regex)
(Select-String -Path $filepath -Pattern $yesterday -SimpleMatch).Line | Set-Content -Path $out
