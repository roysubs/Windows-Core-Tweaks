
# Enables Hidden files and folders and make file extensions visible, settings that I also use):
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key ShowSuperHidden 1
Set-ItemProperty $key HideFileExt 0
# Stop-Process -processname explorer   # only reset this once at end of script

# I almost never use the "Details" View in Windows because I seldom care about the size of a file or its "Type" or "File Modified" date
# I mostly want to see the file and folder names and then work from there, and the way to do that is "List" view

# https://stackoverflow.com/questions/65166834/enforce-list-view-on-all-windows-explorer-views-including-all-media-folders/65297018#65297018

# *** Change the value of $Backup to the path of an existing folder
# *** where you want to registry backups saved to.
$backup   = "C:\Users\$env:USERNAME\Documents\Backup\Folder View Defaults"
# ----------------------------------------------------------------
# Paths for Powershell commands use the registry Get-PSDrives, hence the ':'
$src = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes'
$dst = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes'
$TVs = "$dest\*\TopViews\*"
# ----------------------------------------------------------------
# Paths for reg.exe commands do not use a ':'
$bagMRU   = 'HKCR\Local Settings\Software\Microsoft\Windows\Shell\BagMRU'
$bags     = 'HKCR\Local Settings\Software\Microsoft\Windows\Shell\Bags'
$defaults = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Defaults'
# ----------------------------------------------------------------
# Backup & then delete saved views and 'Apply to folders' defaults
reg export $BagMru "$Backup\bagMRU.reg"
reg export $Bags "$Backup\bags.reg"
reg export $Defaults "$Backup\defaults.reg"
reg delete $bagMRU /f
reg delete $bags /f
reg delete $defaults /f
reg delete ($dest.Replace(':','')) /f
#------------------* The Magic is here *--------------------------
# Copy HKLM\...\FolderTypes to HKCU\...\FolderTypes
Copy-Item $src "$(Split-Path $dst)" -Recurse
# Set all 'LogicalViewMode' values to the desired style
# 1 = Details   2 = Tiles   3 = Icons   4 = List   5 = Content
# Edit "$key2edit.SetValue('LogicalViewMode', 4)" as desired

Get-ChildItem $TVs | % {
    $key2edit = (get-item $_.PSParentPath).OpenSubKey($_.PSChildName, $True);
    $key2edit.SetValue('LogicalViewMode', 4)   # <== Set this value to the view required
    $key2edit.Close()    
}

