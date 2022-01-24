# Snippets, do not run this script as is ...
exit

# Extract each zipfile to its own folder
# capture the stuff you want here as array
$zipfiles = ls C:\Downloads\*.zip
$info = foreach ($zip in $zipfiles) { 
    $zip.Name   # output whatever you want collected in $info, to show later if required
    $dst = Join-Path -Path $zip.DirectoryName -ChildPath $zip.BaseName   # construct the folderpath for the unzipped files
    if (!(Test-Path $dst -PathType Container)) {
        $null = New-Item -ItemType Directory $dst -ErrorAction SilentlyContinue
        $null = Expand-Archive -LiteralPath $zip.FullName -DestinationPath $dst -ErrorAction SilentlyContinue
    }
}
# now you can create a multiline string from the $info array
$result = $info -join "`r`n==========`r`n"

Compress-Archive -Path D:\path\to\file.txt -DestinationPath D:\path\to\archive.zip



# Get all lines from $filepath (possibly a log file) that matches a date string ($yesterday)
$yesterday = '{0:yyyy-MM-dd}' -f (Get-Date).AddDays(-1)
$out = Join-Path -Path ([System.IO.Path]::GetDirectoryName($filepath)) -ChildPath ("log_{0}.log" -f $yesterday)
# use SimpleMatch because the pattern is to be taken literally (no regex)
(Select-String -Path $filepath -Pattern $yesterday -SimpleMatch).Line | Set-Content -Path $out



# Prevent the first run requirement for Internet Explorer for scripting
# https://stackoverflow.com/questions/38005341/the-response-content-cannot-be-parsed-because-the-internet-explorer-engine-is-no
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2
