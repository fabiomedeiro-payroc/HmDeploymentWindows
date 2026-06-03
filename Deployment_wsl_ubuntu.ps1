#Requires -RunAsAdministrator

function ex { exit }

$HomeVirtualboxExecutable = "$HOME\Downloads\VirtualBox-7.2.8-173730-Win.exe"
$HomeVirtualbox           = "C:\Program Files\Oracle\VirtualBox"
$HomePuttyExecutable      = "$HOME\Downloads\putty-64bit-0.78-installer.msi"
$HomeVisualCExecutable    = "$HOME\Downloads\vc_redist.x64.exe"
$WSLConfig                = "$HOME\.wslconfig"

# --- Visual C++ Redistributable ---
$URL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
if (-not [System.IO.File]::Exists($HomeVisualCExecutable)) {
    Write-Host "Downloading Visual C++"
    Invoke-WebRequest -Uri $URL -OutFile $HomeVisualCExecutable
}
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\DevDiv\VC\Servicing\14.0\RuntimeMinimum")) {
    Write-Host "Installing Visual C++"
    Start-Process -FilePath $HomeVisualCExecutable -ArgumentList "/q /norestart" -Wait
}

# --- VirtualBox ---
$URL = "https://download.virtualbox.org/virtualbox/7.2.8/VirtualBox-7.2.8-173730-Win.exe"
if (-not [System.IO.File]::Exists($HomeVirtualboxExecutable)) {
    Write-Host "Downloading VirtualBox 7.2.8"
    Invoke-WebRequest -Uri $URL -OutFile $HomeVirtualboxExecutable
}
if (-not (Test-Path $HomeVirtualbox)) {
    Write-Host "Installing VirtualBox 7.2.8"
    Start-Process -FilePath $HomeVirtualboxExecutable -ArgumentList "--silent" -Wait
}

# --- Windows Optional Features ---
Write-Host "Preparing windows to enable some feature"
Start-Process C:\Windows\System32\OptionalFeatures.exe
Write-Host "Checking Windows features..."
if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Disabled") {
    Write-Host "Enabling WSL"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}
if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online).State -eq "Disabled") {
    Write-Host "Enabling Virtual Machine Platform"
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
}
if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online).State -eq "Disabled") {
    Write-Host "Enabling Hyper-V"
    dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
}

# --- Windows Terminal ---
Write-Host "Installing Windows Terminal"
winget install --silent --accept-package-agreements --accept-source-agreements --id 9N0DX20HK701 --source msstore

# --- WSL ---
Write-Host "Updating WSL"
wsl --update
Write-Host "Setting WSL default version to 2"
wsl --set-default-version 2
Write-Host "Installing Ubuntu 22.04"
wsl --install -d Ubuntu-22.04

# --- WSL Network Config (.wslconfig) ---
Write-Host "Configuring WSL network settings for VPN compatibility..."
$wslConfigContent = @"
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=false
"@
if (-not (Test-Path $WSLConfig)) {
    Write-Host "Creating $WSLConfig"
    Set-Content -Path $WSLConfig -Value $wslConfigContent
} else {
    $existingContent = Get-Content $WSLConfig -Raw
    }
}

Write-Host "Restarting WSL to apply network config..."
wsl --shutdown
Write-Host "Done! Launch Ubuntu from the Start Menu or run: wsl"
