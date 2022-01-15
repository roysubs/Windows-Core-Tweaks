# Correctly enable ways to remotely access this system.
####################
# This is because it is impossible to remotely configure a Windows client to allow remote access (either via
# Remote Desktop, or networking, or PS Remoting) since all access methods require some change to the remote
# system by a local user.

# Also note to dismiss the "Sign in with Microsoft account" false Security warning from Windows Defender ...
# This is Microsoft pushing people to use Microsoft accounts, just press dismiss for this and use local accounts.



# Enable "Remote Desktop"
####################
# These two lines are enough to get started, as can do all remote configuration via remote desktop afterwards.
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"



# Enable File Sharing
####################
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# Properly Enable PowerShell Remoting
####################
# https://www.mobzystems.com/blog/configuring-powershell-remoting-with-network-access/
# https://serverfault.com/questions/243493/powershell-remote-sessions-and-access-to-network-resources
# https://devblogs.microsoft.com/powershell/credssp-for-second-hop-remoting/
# PS C:\> $r = New-PSSession
# PS C:\> icm $r {Get-PfxCertificate c:\monad\TestpfxFile.pfx}
#    Enter password:
#    Invoke-Command : The requested operation cannot be completed. The computer must be trusted for delegation and the current user account must be configured to allow delegation.
#    At line:1 char:4
#        + icm <<<<  $r {Get-PfxCertificate c:\monad\TestpfxFile.pfx}
PowerShell remoting supports a new authentication mechanism called CredSSP.  “CredSSP enables an application to delegate the user’s credentials from the client (by using the client-side SSP) to the target server (through the server-side SSP).”   See the following link for more info: http://blogs.msdn.com/windowsvistasecurity/archive/2006/08/25/724271.aspx  Here is a link to the CredSSP protocol specification: http://download.microsoft.com/download/9/5/E/95EF66AF-9026-4BB0-A41D-A4F81802D92C/%5BMS-CSSP%5D.pdf

To enable client-side SSP for winrm, run the following lines:
Enable-WSManCredSSP -Role client -DelegateComputer *

To enable server-side SSP for winrm:
Enable-WSManCredSSP -Role server

Now let’s try the same scenario with a remote runspace created with CredSSP authentication.

PS C:\> $r = New-PSSession Fully.Qualified.Domain.Name -Auth CredSSP -cred domain\user
PS C:\> icm $r {Get-PfxCertificate c:\monad\TestpfxFile.pfx} | fl
Subject      : CN=Hula Monkey, OU=checkins, OU=monad
Issuer       : CN=Hula Monkey, OU=checkins, OU=monad
Thumbprint   : 613F82CEAF98C2457BD140AF3FBF7045FFFBAC90
FriendlyName :
NotBefore    : 7/7/2004 4:15:37 PM
NotAfter     : 12/31/2039 3:59:59 PM
Extensions   : {System.Security.Cryptography.Oid, System.Security.Cryptography.Oid}
ComputerName : Fully.Qualified.Domain.Name
PS C:\> icm $r {$s=new-pssession}
PS C:\> icm $r {icm $s {whoami}}
domain\user
PS C:\>
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
#   Enable-WSManCredSSP Client -DelegateComputer <host-name>
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
#        # Running on $env:ComputerName
#    } # Credential (Get-Credential user-name)
