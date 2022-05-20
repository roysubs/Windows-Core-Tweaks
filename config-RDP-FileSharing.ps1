# Enable "Remote Desktop"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
# This is enough to get started, can do all remote configuration via remote desktop after these two commands.

# Dismiss the "Sign in with Microsoft account" false Security warning ... (annoying)
# Just press dismiss for this and continue to login with a normal account

# Enable File Sharing
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

### Enable PowerShell Remoting
# https://www.mobzystems.com/blog/configuring-powershell-remoting-with-network-access/
# https://serverfault.com/questions/243493/powershell-remote-sessions-and-access-to-network-resources
# https://devblogs.microsoft.com/powershell/credssp-for-second-hop-remoting/

Enable-PSRemoting   # Can then use:   Enter-PSSession <host-name>
# However, you will not be able to access any network resources on the host because of the double hop problem:
# connecting PSDrives or running net use will ask for your credentials and fail.
# To remedy that, we have to allow the host to respond to CredSSP-type connections and to configure the client
# to delegate credentials to the host.
# Allow the host to respond incoming CredSSP connections, as Administrator, run:
Enable-WSManCredSSP Server   # Enables CredSSP authentication mechanism for incoming sessions on the host

### Configuring the client
# Next, the client (the computer the remote session connects from) has to be configured to trust one of more
# hosts to forward credentials to. Within domains, there is usually just one step; across domains, we need another.
# Allow the client to delegate credentials to the host
# Another command needs to be run on the client computer, again in an Administrator Powershell prompt:
Enable-WSManCredSSP Client -DelegateComputer host-name
# This adds host-name to the list of computers the client will forward credentials to (when using CredSSP).
# You can specify a single host name, or use the *.domain.com syntax.
# In the latter case, make sure you specify the complete host name, as in host1.domain.com and not just host1.
# You can even specify a list, as in
#   Enable-WSManCredSSP Client -DelegateComputer host1, host2, host3
# To clear the entire list of hosts, run
#   Disable-WSManCredSSP Client
# Then, optionally add back the required hosts using Enable-WSManCredSSP.

### (Optional) Trust the host if it is in another domain
# This enables you to pass credentials to a host that is not in your domain.
# Using an Administrator Powershell prompt on the client, type:
#   (Get-Item wsman:\localhost\client\TrustedHosts).Value
# The result is a list of the hosts that the client trusts enough to send it your credentials when
# connecting a Powershell session. An asterisk * trusts all hosts, or *.domain.com trusts all hosts in a domain.
# Set the value using:
#   Set-Item wsman:\localhost\client\TrustedHosts -Value your-host-list
# Note that you're not adding to the list here, but replacing the entire list.

# Setting up a session
# Because we're using CredSSP, setting up a session is a little more complicated.
# We have to specify the authentication type and supply credentials:
#    Enter-PSSession host-name -Authentication CredSSP -Credential (Get-Credential username)
# The Get-Credential command will prompt the user for a password, with the user name username already in place.
# Similarly, you can run a command on a remote computer (or on a list of remote computers!) using:
#    Invoke-Command -Authentication CredSSP -ComputerName host1, host2 -ScriptBlock {
#        â€œRunning on $env:ComputerNameâ€
#    } â€“Credential (Get-Credential user-name)