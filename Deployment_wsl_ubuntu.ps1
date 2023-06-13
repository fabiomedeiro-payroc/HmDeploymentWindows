function ex{exit}
New-Alias ^D ex

$URL = "https://download.virtualbox.org/virtualbox/6.1.44/VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualboxExecutable = "$HOME\Downloads\VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualbox = "C:\Program Files\Oracle\VirtualBox"
$HomeOpenVpnExecutable = "$HOME\Downloads\OpenVPN-2.6.4-I001-amd64.msi"
$HomeOpenVpn = "C:\Program Files\OpenVpn"
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

$URL = "https://swupdate.openvpn.org/community/releases/OpenVPN-2.6.4-I001-amd64.msi"

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
$HomeOpenVpnConfig = "C:\Program Files\OpenVPN\config\DublinOpenVpn.ovpn"
$URL = "https://raw.githubusercontent.com/fabioamedeiro/HmDeploymentWindows/main/Dublin_OpenVPN.ovpn"

if (!([System.IO.File]::Exists($HomeOpenVpnConfig )))
{
    echo "Downloading OpenVPN"
    Invoke-WebRequest -Uri $URL -OutFile $HomeOpenVpnConfig
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
wsl --set-default-version

echo "Install WSL command"

wsl --install -d Ubuntu-22.04

