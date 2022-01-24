Exporting / Importing a Start Menu layout. First, Log on to a Windows 10 machine that has all of the software you want to be pinned on the Start Menu layout and customise the Start Menu as you want it.
Once you have it how you want, run the following command in an elevated PowerShell session:
Export-StartLayout -UseDesktopApplicationID -Path C:\StartMenuLayout.xml

If all you wish to do is have a custom default Start Menu in place for all users of a computer, then you can run the following PowerShell command to set the layout as the default:
Import-StartLayout -LayoutPath "C:\StartMenuLayout.xml" -MountPath $env:SystemDrive\

For more complex setups, you have to edit the XML, see https://gal.vin/posts/old/start-menu-and-taskbar-customisation/
