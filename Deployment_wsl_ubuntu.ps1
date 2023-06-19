function ex{exit}
New-Alias ^D ex

$URL = "https://download.virtualbox.org/virtualbox/6.1.44/VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualboxExecutable = "$HOME\Downloads\VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualbox = "C:\Program Files\Oracle\VirtualBox"
$HomeOpenVpnExecutable = "$HOME\Downloads\openvpn-connect-3.3.7.2979_signed.msi"
$HomeOpenVpn = "C:\Program Files\OpenVpn Connect"
$OpenVpnConfig = "$HOME\Downloads\DublinOpenVpn.ovpn"

if (!([System.IO.File]::Exists($HomeVirtualboxExecutable )))
{
    echo "Downloading VirtualBox 6.1.44"
    Invoke-WebRequest -Uri $URL -OutFile $HomeVirtualboxExecutable
}

if (!(Test-Path -Path $HomeVirtualbox))
{
    echo "Installing Virtulbox 6.1.44"
    start-process ($HomeVirtualboxExecutable)  --silent
}

$URL = "https://swupdate.openvpn.net/downloads/connect/openvpn-connect-3.3.7.2979_signed.msi"

if (!([System.IO.File]::Exists($HomeOpenVpnExecutable )))
{
    echo "Downloading OpenVPN"
    Invoke-WebRequest -Uri $URL -OutFile $HomeOpenVpnExecutable
}


if (!(Test-Path -Path $HomeOpenVpn))
{
    echo "Installing OpenVPN"
    msiexec.exe /i $HomeOpenVpnExecutable /quiet
}

$URL = "https://raw.githubusercontent.com/fabioamedeiro/HmDeploymentWindows/main/Dublin_OpenVPN.ovpn"

if (!([System.IO.File]::Exists($OpenVpnConfig )))
{
    echo "Downloading OpenVPN Config"
    Invoke-WebRequest -Uri $URL -OutFile $OpenVpnConfig


    echo "Importing OpenVPN Config"
    & C:\"Program Files"\"OpenVpn Connect"\OpenVPNConnect.exe  --accept-gdpr --skip-startup-dialogs --import-profile=$OpenVpnConfig
}

if(!((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Enabled"))
{
    echo "Enabling WSL"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    Restart-Computer
}
if (!((Get-CimInstance win32_processor).VirtualizationFirmwareEnabled))
{
    echo "Enable Virtual Machine feature"
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Restart-Computer
}
if ($hyperv.State -eq "Enabled")
{
    echo "Deactivating hyper-V"
    bcdedit /set hypervisorlaunchtype off
    Restart-Computer
}

echo "WSL updating"
wsl --update

echo "Set WSL 1 as your default version"
wsl --set-default-version 1

echo "Install WSL command"

wsl --install -d Ubuntu-22.04
