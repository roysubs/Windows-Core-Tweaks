####################
###   Basic setup after complete Reset of Windows
####################

####################
# Manual Tasks
####################
# - To get a non-Microsoft Local Account after Reset, select "Join a Domain" during setup to bypass Hotmail setup,
# - Change the hostname:   Rename-Computer -NewName "Asus"
# - Use Storage sense to remove Windows.old (which uses Disk cleanup internally)
# - Set PowerShell Execution Policy from elevated PowerShell prompt (update-help, help about_execution_policies)
#      Set-ExecutionPolicy RemoteSigned
# - Install Chocolatey from an elevated PowerShell prompt
#      Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# - Enable RDP (this is enough to do all remote configuration via remote desktop after these two commands.
#      Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
#      Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
# - Enable Network Discovery / FileSharing
#      netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

pause
####################
# The following commands require that the above are done before running
# Ideally test if the above are done here to ensure that choco is installed, execution policy etc
####################

### Manually get these configuration scripts into %temp% / $env:Temp
# Note: also worth following the "Windows Decrapifier" project for ways to minimise Windows setup
choco install git.install -y
git clone https://github.com/roysubs/Windows-Core-Tweaks $env:Temp\Windows-Core-Tweaks

### Setup Chrome and Notepad++
choco install googlechrome notepadplusplus.install   # Need to use .install for notepadplusplus to do a full install
# - To replace Notepad by Notepad++, must run this (just replaces notepad by notepad++ directly for all situations)
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "Debugger" /t REG_SZ /d "\"%ProgramFiles%\Notepad++\notepad++.exe\" -notepadStyleCmdline -z" /f
# Now change Notepad++ settings:
# - Enable Dark Mode: Settings > Preferences > Dark Mode
# - Enable AutoSave (will operate like VS Code, remember last session and save every 7 seconds): Settings > Preferences > Backups > Session snapshot and periodic backup
#      Default backup location will be: C:\Users\Boss\AppData\Roaming\Notepad++\backup\

### Less noisy notifications sounds
# The default Windows sounds are annoying and jarring, ding.wav is much shorter and less annoying so replace various sounds by this."
$toChange = @('.Default','SystemAsterisk','SystemExclamation','Notification.Default','SystemNotification','WindowsUAC','SystemHand')
foreach ($c in $toChange) { Set-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\.Default\$c\.Current\" -Name "(Default)" -Value "C:\WINDOWS\media\ding.wav" }

### Essential default applications
# By having them controlled by Chocolatey, will be easier to update in future
choco install vscode.install autohotkey.install javaruntime   
choco install mpc-hc ditto sumatrapdf
# Can now turn off all annoying autoupdates for MPC-HC / Java / VS Code / Macrium Reflect, as updates can be delivered by Chocolatey
# MPC-HC, at startup, it asks if you want updates, select no, then just control them via Chocolatey
# Java, how to turn off updates, can Chocolatey handle this ok?
# VS Code, how to turn off updates, can Chocolatey handle this ok?
# Macrium Reflect, go to Help > Configure Update Check... > Turn off both update notification options, Chocolately will update as required

### Optional:
# choco install hamachi reflect-free
# choco install goggalaxy
### To setup Steam, with installed games on D:
# By redirecting to D:\, it is easier to Reset the system, can install Steam manually to D:\ or if it already exists there,
# can just repair the existing installation, by double-click steam.exe after OS reinstall (will find all installed games and enable them).
# I keep this at "D:\O Cloud\Steam" beside other Cloud apps (OneDrive, Google Drive, Dropbox)
### For GOG Galaxy, install with chocolatey (goggalaxy packagE) to it's default location at C:\Program Files (x86)\GOG Galaxy
# Then, log in to GOG, and go to Settings > Installing, updating > Game installation folder
# Change this to: D:\0 Cloud\GOG Galaxy
# Now go to Installed > Press the "+" at top > "Scan folders for GOG games"
# Select the folder with the games, and then will all be indexed correctly.

### You can now update all Chocolatey maintained packages at any time with:
cup all -y

### Cloud Applications (default to "D:\0 Cloud")

### Do all of these as manual setups (non-chocolatey):
# D:\0 Cloud\OneDrive      # Installed by default with Windows
# D:\0 Cloud\Google Drive
# D:\0 Cloud\Dropbox

# After installing OneDrive, if you had existing files in that folder, often the permissions will be set to read-only (since Chocolatey installs as Admin)
# We have to give FullControl permissions to Everyone on that folder and all subfolders
$path = 'D:\0 Cloud\OneDrive'
if (Test-Path -Path $path) {    # New-Item -Path $path -ItemType directory
    $acl = Get-Acl -Path $path
    $permission = 'Everyone', 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'
    $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission
    $acl.SetAccessRule($rule)
    $acl | Set-Acl -Path $path
}

### Manul MPC-HC Setup, change options and associate all video files with MPC-HC
# Launch MPC-HC
#    Ctrl+A (turn on Always On Top), Ctrl+0 (turn off Menus; can access all via right-click anyway).
#    Ctrl+2 (turn off Controls), Ctrol+5 (turn off Status)
#    Probably leave the Seek Bar on (i.e. do not press Ctrl+1)
#    View > Options > Player > Open a new player for each video file played
#        Snap to Desktop edges
#        Check all "Remember" settings except for "Pan n Scan"
#    View > Options > Player > Format (click run as admin), press the "all video formats" (button with "v" on it) and click Apply.
# After that MPC-HC should appear as a choice for the default video player.
# i.e. Start > "default" to get to Default Programs, then change Video to MPC-HC

# https://www.simplehelp.net/2021/03/06/windows-app-of-the-month-sumatra-pdf/
# https://www.sumatrapdfreader.org/docs/Keyboard-shortcuts
# Associate files with Sumatra-PDF
# Sumatra > Settings > Options > Fit to Width, uncheck "Show bookmark sidebar", uncheck "Remember opened files"
#    uncheck automatically update (chocolatey will do it anyway)
# https://danysys.com/powershell-set-file-type-association-default-application-windows-10/
git clone https://github.com/DanysysTeam/PS-SFTA $env:Temp\PS-SFTA
. $env:Temp\PS-SFTA\SFTA.ps1
Set-FTA Applications\SumatraPDF.exe .pdf
Register-FTA "C:\SumatraPDF.exe" .pdf -Icon "shell32.dll,100"
Set-FTA Applications\SumatraPDF.exe .epub
Set-FTA Applications\SumatraPDF.exe .mobi
Set-FTA Applications\SumatraPDF.exe .cbz
Set-FTA Applications\SumatraPDF.exe .cbr
Set-FTA Applications\SumatraPDF.exe .xps
Set-FTA Applications\SumatraPDF.exe .chm
Set-FTA Applications\SumatraPDF.exe .djvu
# Set Sumatra PDF as Default .pdf reader from Windows Command Processor (cmd.exe):
# powershell -ExecutionPolicy Bypass -command "& { . .\SFTA.ps1; Set-FTA 'Applications\SumatraPDF.exe' '.pdf' }"
# https://superuser.com/questions/1170135/script-to-change-the-file-type-association-for-pdf-files-on-windows-10

### Manual tasks:
# Setup Office 365, OneNote 2016 (chocolatey?)
# Configure OneNote 2016 account
# Configure AnyDesk servers

### ToDo
# ToDo: PowerShell / Task Scheduler => Automate Chocolatey check that will update everything on each reboot (and/or at every day at 3am? How to do this).
# ToDo: PowerShell / Task Scheduler => Automate start Basics.ahk.
# Task that runs same script at 3am (but only if no activity detected for 15 minutes?)

### OneNote & Office
cinst onenote -y --ignore-checksum   # Have to use --ignore-checksum https://community.chocolatey.org/packages/onenote/16.0.14931.20132
cinst Office365ProPlus -y

### Summarised main app setups:
# Set-ExecutionPolicy RemoteSigned
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
# cinst -y Brave Firefox   # GoogleChrome
# cinst -y vscode.install git.install javaruntime autohotkey.install
# cinst -y 7zip notepadplusplus.install ditto mpc-hc-clsid2 sumatrapdf signal anydesk.install calibre nordvpn reflect-free goggalaxy
# cinst -y putty vcxsrv
# cinst -y office365proplus onedrive
# cinst -y onenote --ignore-checksum
# wsl --install -d Ubuntu

####################
###   WSL with WSLg (requires Insider Build on the 'Dev' channel)
####################
# The Windows Subsystem for Linux GUI (WSLg) was officially released at the Microsoft Build 2021 conference and comes with Windows 10 Insider build 21364 or later.
# https://www.bleepingcomputer.com/news/microsoft/hands-on-with-wslg-running-linux-gui-apps-in-windows-10/

# Go to Settings > Updates > Windows Insider Programme
# Note that this can only be done by switching to a Microsoft account(!)
# After updating to the Insider Programme, install WSL (Windows Subsystem for Linux)
#    wsl --install -d Ubuntu   # From elevated PowerShell => initially about 1.1 GB, at C:\Users\Boss\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc
#    wsl --install -d Debian   # From elevated PowerShell => initially about 0.3 GB, at C:\Users\Boss\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc
#    Note: Debian requires    sudo setcap cap_net_raw+p /bin/ping      [ https://github.com/microsoft/WSL/issues/5109 ]
# Can get to a distro easily with:   cd $env:UserProfile\AppData\Local\Packages\Canonical*
#    cd $env:localappdata\Packages\*Debian*
# This will require a reboot, after which Ubuntu will start automatically, installation will take a few minutes, showing the following:
#    Installing, this may take a few minutes...
#    Please create a default UNIX user account. The username does not need to match your Windows username.
#    For more information visit: https://aka.ms/wslusers
#    Enter new UNIX username:
# The image is initially 1.09 GB and is located at:
#    PS C:\Users\Boss\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc>
# For existing WSL users, you need to update WSL to add support for the WSLg engine
#    wsl --update
#       Checking for updates...
#       Downloading updates...
#       Installing updates...
#       This change will take effect on the next full restart of WSL. To force a restart, please run 'wsl --shutdown'.
#       Kernel version: 5.10.60.1
#    wsl --shutdown   # To fully restart WSL
# Once WSL is updated, make sure your Linux distribution is configured to use WSL 2
#    wsl --list -v
# If the distribution you want to use is version 1, you need to upgrade it to version 2
#    wsl --set-version <distro_name_> 2
#    wsl --set-version ubuntu 2
# For better performance in WSLg, Microsoft recommends that you install the following preview drivers:
# AMD GPU driver for WSL, Intel GPU driver for WSL, and NVIDIA GPU driver for WSL.
# https://www.amd.com/en/support/kb/release-notes/rn-rad-win-wsl-support   (AMD is a 469 GB download)
# Once your distribution is upgraded, you can now use WSLg to run Linux GUI apps.
#
# A few examples:
#    sudo apt install Nautilus
#    nautilus
#    sudo apt install stacer
#    stacer
#    sudo apt install timeshift
#    sudo timeshift-gtk
#    sudo apt install hedgewars
#    hedgewars

### uTorrent Setup
# Go to preferences and disable all of the folloing:
#    bt.enable_pulse
#    gui.show_notorrents_node
#    gui.show_plus_upsell
#    offers.content_offer_autoexec
#    offers.left_rail_offer_enabled
#    offers.sponsored_torrent_offer_enabled
#
# Suppress ads from 1337x.to    # https://www.myantispyware.com/2020/03/11/how-to-remove-1337x-to-pop-up-ads-virus-removal-guide/
# chrome://settings/content/notifications
# Remove the 1337x.to site and other questionable URLs by clicking the three vertical dots button next to each and selecting 'Remove'
#
# NordVPN KillSwitch by App: add the two uTorrent processes

### Auto-logon (for TV computer etc). 
# netplwiz   # Just uncheck the Users must use a password. This will not work on corporate domain laptops.
# Could also try this for domain accounts:
# https://www.alphr.com/how-to-enable-auto-login-in-windows-10/

### Keep Alive technique (seems to also work on ING laptop)
# https://www.reddit.com/r/UnethicalLifeProTips/comments/fla86w/ulpt_for_everyone_working_from_home_and_want_to/
