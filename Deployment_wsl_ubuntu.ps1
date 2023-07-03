function ex{exit}
New-Alias ^D ex

$URL = "https://download.virtualbox.org/virtualbox/6.1.44/VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualboxExecutable = "$HOME\Downloads\VirtualBox-6.1.44-156814-Win.exe"
$HomeVirtualbox = "C:\Program Files\Oracle\VirtualBox"
$HomeOpenVpnExecutable = "$HOME\Downloads\openvpn-connect-3.3.7.2979_signed.msi"
$HomeOpenVpn = "C:\Program Files\OpenVpn Connect\OpenVPNConnect.exe"
$OpenVpnConfig = "$HOME\Downloads\DublinOpenVpn.ovpn"
$HomeTortoiseSVNExecutable = "$HOME\Downloads\TortoiseSVN-1.14.5.29465-x64-svn-1.14.2.msi"
$HomePuttyExecutable = "$HOME\Downloads\putty-64bit-0.78-installer.msi"


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

$URL = "https://raw.githubusercontent.com/fabioamedeiro/HmDeploymentWindows/main/Dublin_OpenVPN.ovpn"

if (!([System.IO.File]::Exists($OpenVpnConfig )))
{
    echo "Downloading OpenVPN Config"
    Invoke-WebRequest -Uri $URL -OutFile $OpenVpnConfig

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
	Start-Sleep -Seconds 10
	
	echo "Importing OpenVPN Config"
	& C:\"Program Files"\"OpenVpn Connect"\OpenVPNConnect.exe --accept-gdpr --skip-startup-dialogs --import-profile=$OpenVpnConfig
}

$URL = "https://free.nchc.org.tw/osdn//storage/g/t/to/tortoisesvn/1.14.5/Application/TortoiseSVN-1.14.5.29465-x64-svn-1.14.2.msi"

if (!([System.IO.File]::Exists($HomeTortoiseSVNExecutable )))
{
    echo "Downloading TortoiseSVN"
    Invoke-WebRequest -Uri $URL -OutFile $HomeTortoiseSVNExecutable

    echo "Installing TortoiseSVN"
    msiexec.exe /i $HomeTortoiseSVNExecutable /quiet
}

$URL = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.78-installer.msi"

if (!([System.IO.File]::Exists($HomePuttyExecutable )))
{
    echo "Downloading TortoiseSVN"
    Invoke-WebRequest -Uri $URL -OutFile $HomePuttyExecutable

    echo "Installing TortoiseSVN"
    msiexec.exe /i $HomePuttyExecutable /quiet
    Start-Sleep -Seconds 10
}

echo "Preparing windows to enable some feature"
C:\Windows\System32\OptionalFeatures.exe

echo "Checking if Microsoft-Windows-Subsystem-Linux feature is enabled"

if((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Disabled")
{
    echo "Enabling WSL"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all 
}

echo "Checking if VirtualMachinePlatform feature is enabled"

if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform  -Online).State -eq "Disabled")
{
    echo "Enable Virtual Machine feature"
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all  
}

echo "Checking if Microsoft-Hyper-V feature is enabled"

if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V  -Online).State -eq "Enabled")
{
    echo "Deactivating hyper-V"
    dism.exe /online /disable-feature /featurename:Microsoft-Hyper-V 
 
}



echo "WSL updating"
wsl --update

echo "Set WSL 1 as your default version"
wsl --set-default-version 1

echo "Install WSL command"

wsl --install -d Ubuntu-22.04
