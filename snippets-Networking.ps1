
# Discover the WiFi password currently in use on this host
$Profile = Netsh wlan show profile name=(Get-NetConnectionProfile -InterfaceAlias WLAN).Name key=clear
if ($Profile -Match '((????|Key Content)\s*\:\s*)\S+') { $Matches[0] }
