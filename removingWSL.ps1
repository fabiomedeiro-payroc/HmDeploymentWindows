if((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Enabled")
{
    echo "removing the vm ubuntu 22.04"
    wsl --unregister Ubuntu-22.04
    echo "Removing Ubuntu 22.04"
    winget uninstall -h --id=9PN20MSR04DW
    echo "Removing the Windows subsystem Linux app"
    winget uninstall -h --id=9P9TQF7MRM4R
    echo "Disable  WSL feature"
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Restart-Computer

}
