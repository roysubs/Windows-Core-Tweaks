# Change to large (64-point) Windows Mouse and Cursor with PowerShell
$RegConnect             = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser", "$env:COMPUTERNAME")
$RegCursorsAccess       = $RegConnect.OpenSubKey("Software\Microsoft\Accessibility", $true)
$RegCursorsControlPanel = $RegConnect.OpenSubKey("Control Panel\Cursors", $true)

# In the code below I'm trying to change the size of the cursor.
$RegCursorsControlPanel.SetValue("CursorBaseSize", 48)
$RegCursorsAccess.SetValue("CursorSize", 3)

$RegCursorsAccess.Close()
$RegConnect.Close()

# This section is where I thought it would update the cursor size.
# Here is where it lists stuff relating to setting and updating any settings changed.
# https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa
    # SPI_SETCURSORS
    # 0x0057
    # Reloads the system cursors. Set the uiParam parameter to zero and the pvParam parameter to NULL.

$CSharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
# $CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)
$CursorRefresh::SystemParametersInfo(0x2029, 0, 64, 0x01);