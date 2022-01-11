# Remove junk from new Taskbar and setup my preferences
####################

# Disable "Meet now"
####################

# [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
# "HideSCAMeetNow"=dword:00000001
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
# "HideSCAMeetNow"=dword:00000001



# Turn off "News and interests" (long method, but comprehensive for silent configuration settings)
####################
# https://silentinstallhq.com/disable-news-and-interests-from-windows-10-taskbar-for-all-users-powershell/



# Disable Search box and Cortana on the Taskbar
####################
# https://admx.help/HKLM/SOFTWARE/Policies/Microsoft/Windows/Windows%20Search
function Update-Registry ($RegPath, $Item, $Value) {
    $Path = Split-Path $RegPath ; $Name = Split-Path $RegPath -Leaf
    if (!(Test-Path -Path $RegPath)) { New-Item -Path $Path -Name $Name -Force }
    if (!(Test-Path -Path "$RegPath\$Item")) { New-ItemProperty -Path $Path -Name $Item -Value $Value -Force }
    Set-ItemProperty -Path $RegPath -Name $Item -Value $Value
}
Update-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Update-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0



# Set "Combine taskbar buttons" to "Never".   # http://superuser.com/questions/135015
# I dislike icons-only, and all stacked, I like to see that apps are open due to name tag beside them.
$taskbarButtonsRegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
if (((Get-ItemProperty -path $taskbarButtonsRegKey ).TaskbarGlomLevel ) -Ne 2) {
    Set-ItemProperty -Path $taskbarButtonsRegKey -Name "TaskbarGlomLevel" -Value 00000002
}

Stop-Process -Name Explorer
& Explorer.exe

