#Deploying Brew 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Adding brew to PATH
echo >> /Users/$USER/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

#Deploying Virtualbox
brew install virtualbox

#Deploying Chrome
brew install google-chrome

#Deploying  Openvpn
brew install openvpn-connect

#Deploying Slack
brew install slack

#Deploying git subversion vagrant 
brew install git subversion vagrant wget

#Deploying python3
brew install python@3.9

#Deploying Ansible
/opt/homebrew/bin/python3.9 -m pip install ansible==5.10.0
