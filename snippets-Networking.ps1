# Prevent the first run requirement for Internet Explorer for scripting
# https://stackoverflow.com/questions/38005341/the-response-content-cannot-be-parsed-because-the-internet-explorer-engine-is-no
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

# Discover the WiFi password currently in use on this host
$Profile = Netsh wlan show profile name=(Get-NetConnectionProfile -InterfaceAlias WLAN).Name key=clear
if ($Profile -Match '((????|Key Content)\s*\:\s*)\S+') { $Matches[0] }
