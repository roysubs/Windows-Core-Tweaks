# Remove junk from new Taskbar and setup sensible defaults
####################
# Disable "Meet now", some Microsoft social or mini-Teams thing. Useless.
# Turn off "News and interests", really annoying junk that is like a Start menu on the Left full of Weather and news junk. Useless.

function Update-Registry ($RegPath, $Item, $Value) {
    $Path = Split-Path $RegPath
    $KeyName = Split-Path $RegPath -Leaf
    if (!(Test-Path -Path $RegPath)) { New-Item -Path $Path -Name $KeyName -Force }
    if (!(Test-Path -Path "$RegPath\$Item")) { New-ItemProperty -Path $Path -Name $Item -Value $Value -Force }
    Set-ItemProperty -Path $RegPath -Name $Item -Value $Value
}

# Disable "Meet now"
####################

# [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
# "HideSCAMeetNow"=dword:00000001
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
# "HideSCAMeetNow"=dword:00000001



# Turn off "News and interests" (long method, but comprehensive for silent configuration settings)
####################
# This works, need to convert to PowerShell way:
# Got it from here: https://community.spiceworks.com/topic/2322894-remove-news-and-interests-taskbar
# Note that it completely removes the News and interests option, so to turn it on, you have to undo the above
# Requires explorer restart
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /T REG_DWORD /V "EnableFeeds" /D 0 /F
# Latest Microsoft patch makes the older methods on sites fail to work, either with my Update-Registry function of long-hand:
# https://silentinstallhq.com/disable-news-and-interests-from-windows-10-taskbar-for-all-users-powershell/
# https://www.prajwaldesai.com/disable-news-and-interests-in-windows-10/#:~:text=Navigate%20to%3A%20HKEY_CURRENT_USER%5CSoftware%5C,completely%20disable%20News%20and%20Interests.
# Update-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2   # Set the value to 2 to completely disable News and Interests.
# Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" | select ShellFeedsTaskbarViewMode   # Get Current Setting before change
# Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2   # Remove News and Interest Using Powershell
# Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" | select ShellFeedsTaskbarViewMode   # Get Current Setting after change



# Disable Search box and Cortana on the Taskbar
####################
# https://admx.help/HKLM/SOFTWARE/Policies/Microsoft/Windows/Windows%20Search
Update-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Update-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0



# Set "Combine taskbar buttons" to "Never".   # http://superuser.com/questions/135015
####################
# I dislike icons-only, and all stacked, I like to see that apps are open due to name tag beside them.
$taskbarButtonsRegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
if (((Get-ItemProperty -path $taskbarButtonsRegKey ).TaskbarGlomLevel ) -Ne 2) {
    Set-ItemProperty -Path $taskbarButtonsRegKey -Name "TaskbarGlomLevel" -Value 00000002
}

Stop-Process -Name Explorer; & Explorer.exe


### # Disable "Meet now"
### # [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
### # "HideSCAMeetNow"=dword:00000001
### # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
### # "HideSCAMeetNow"=dword:00000001
### 
### 
### # Turn off "News and interests"
### # Very long, but comprehensive for silent configuration:
### # https://silentinstallhq.com/disable-news-and-interests-from-windows-10-taskbar-for-all-users-powershell/
### 
### 
### # Disable Search box and Cortana on Start menu
### # https://admx.help/HKLM/SOFTWARE/Policies/Microsoft/Windows/Windows%20Search
### 
### function Update-Registry ($RegPath, $Item, $Value) {
###     $Path = Split-Path $RegPath ; $Name = Split-Path $RegPath -Leaf
###     if (!(Test-Path -Path $RegPath)) { New-Item -Path $Path -Name $Name -Force }
###     if (!(Test-Path -Path "$RegPath\$Item")) { New-ItemProperty -Path $Path -Name $Item -Value $Value -Force }
###     Set-ItemProperty -Path $RegPath -Name $Item -Value $Value
### }
### Update-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
### Update-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
### Stop-Process -Name Explorer
### & Explorer.exe
### 
### New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force
### New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana"
### Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana" 0 -Force
### New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Force
### New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
### Stop-Process -Name Explorer
### & Explorer.exe

