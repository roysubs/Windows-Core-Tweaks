The Following one-liner will setup Chocolatey:
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
   choco list --local-only    # List all installed packages                            # clist -lo
   choco upgrade chocolatey   # Upgrade the Chocolatey package to the latest version   # up chocolatey -y
   choco upgrade all --noop   # List all available upgrades (note, replaces older 'choco version all')   # cup all --noop
   choco upgrade all -y       # Perform all upgrades   # cup all -y

It is often useful to schedule a daily job to upgrade all packages 'choco upgrade all -y' daily during the night: <put method here>

Multiple installs can be shortened to a single line:
    cinst notepadplusplus sysinternals java firefox chrome -y

Most application packages will install to their default install location (i.e. "C:\Program Files (x86)\Notepad++" for the notepadplusplus package)
However, packages that are standalone tools (SysInternals, gsudo, etc) that have no specific install location use a 'shim' per executable.
A package will be in a single folder under. e.g. 'C:\ProgramData\Chocolatey\lib\gsudo'.
Binaries are then placed into a 'tools' subfolder under there. e.g. 'C:\ProgramData\Chocolatey\lib\gsudo\tools'.
Then, a 'shim' is created for each binary under 'C:\ProgramData\Chocolatey\bin'.
Only the bin folder containing the various shim executables are is added to the PATH statement.
Some apps don't do this though. e.g. gsudo actually creates its binary in 'C:\ProgramData\Chocolatey\lib\gsudo\bin'.
And that is on the PATH statement (which seems inefficient but usually they only do this if shims are not possible).
   cinst -y chocolatey.gui      # GUI tool to find packages
   cinst -y chocolatey.server   # Create a standalone Chocolatey server on a PC
   cinst -y boxstarter          # Boxstarter allows automating installs including through reboots

https://github.com/chocolatey/chocolatey.org   # Central location for the Chocolatey Project (package source etc)
https://github.com/chocolatey/choco            # github source
https://github.com/chocolatey/choco/issues     # github issues (post any bugs or feature requests here)
https://gitter.im/chocolatey/home              # Various Chocolatey/Boxstarter chat forums on Gitter
https://gitter.im/chocolatey/choco             # Gitter for choco command line
https://gitter.im/chocolatey/chocolatey.org    # Gitter for chocolatey.org site
https://chocolatey.org/profiles/bcurran3       # Prolific package authors list of packages
https://us8.list-manage.com/subscribe?u=86a6d80146a0da7f2223712e4&id=73b018498d   # Mailing list

Selected packages:
cinst -y 7zip notepadplusplus GoogleChrome Firefox microsoft-windows-terminal bitdefenderavfree greenshot
cinst -y vscode visualstudiocode javaruntime jre8 autohotkey python3 notepadplusplus
cinst -y anydesk teamviewer citrix-receiver hamachi zerotier-one filezilla filezilla.server skype
cinst -y synergy ultramon displayfusion inputdirector sharemouse
cinst -y mpc-hc-clsid2 bbc-iplayer handbrake ffmpeg virtualdub yacreader Paint.NET Gimp ImageMagick
cinst -y bat less git hub gsudo checksum nircmd kindlegen calibre regjump produkey performancetest hwinfo
cinst -y shutup10 recuva wox rainmeter    # Shutup (control Windows telemetry data passed to Microsoft), recuva (Hard disk recovery app), wox (very useful launcher app), rainmeter (customise desktop)  # https://www.slant.co/versus/5390/11687/~wox_vs_launchy
cinst -y PowerToys vlc rufus   # Win10 PowerToys, VLC (I prefer MPC-HC), Rufus (create bootable USB stick)
cinst -y azure-cli azurepowershell nextcloud putty putty.portable
cinst -y sql-server-express sql-server-management-studio
cinst -y DotNet4.5.2 DotNet4.6.1 dotnet4.6.2 KB2919355 KB2919442 KB2999226 KB3033929 KB3035131 
cinst -y vcredist140 vcredist2013 vcredist2015 visualstudio2017-installer visualstudio2017community
cinst -y steam -ia "INSTALLDIR=""D:\0 Cloud\Steam"""            # Install Steam to my preferred custom folder
cinst -y goggalaxy -ia "INSTALLDIR=""D:\0 Cloud\GOG Galaxy"""   # Install GOG Galaxy to my preferred custom folder
cinst -y windows-sandbox vmwareplayer                           # Virtualisation
cinst -y Microsoft-Hyper-V-All -source windowsFeatures          # Hyper-V using WindowsFeatures as a source
cinst -y wsl               # Alternatively:    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
cinst -y wsl-ubuntu-1804 wsl-alpine wsltty   # Download Linux distros for WSL
cinst -y dotnet3.5 dotnet4.5 vcredist2005 vcredist2008 vcredist2010 vcredist2012 vcredist2013   # dotnet4.6 is redundant, part of Win10 build
cinst -y rdmfree terminals rdcman rdtabs mRemoteNG tightvnc ultravnc filezilla filezilla.server
cinst -y lightshot greenshot sharex screenpresso
cinst -y chromium googlechrome firefox
cinst -y wamp-server tomcat apache
