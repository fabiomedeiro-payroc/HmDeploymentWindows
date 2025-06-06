#Deploying Brew 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Adding brew to PATH
echo >> /Users/$USER/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile
eeval "$(/opt/homebrew/bin/brew shellenv)"

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

#Deploying the virtualenv
/opt/homebrew/bin/python3.9 -m pip install virtualenv

#Deploying Ansible
/opt/homebrew/bin/python3.9 -m pip install ansible==5.10.0

#Deploying Maven
brew install maven

#Downloading NVM
wget -P $HOME  https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh ; bash $HOME/install.sh; source $HOME/.nvm/nvm.sh

#Deploying Node
nvm install --lts

softwareupdate --install-rosetta


#Adding the hm entries on hosts file
sudo  sh -c 'printf "\n# IP address of WEB server VM\n192.168.56.3 vagrant.wntps.com\n192.168.56.3 lcashflows.wntps.com\n192.168.56.3 lpayius.wntps.com\n192.168.56.3 lpayjack.wntps.com\n192.168.56.3 lpago.wntps.com\n192.168.56.3 lpivotal.wntps.com\n192.168.56.3 lanywherecom.wntps.com\n192.168.56.3 lctpayment.wntps.com\n192.168.56.3 lpayconex.wntps.com\n192.168.56.3 lpayzone.wntps.com\n192.168.56.3 lgoepay.wntps.com\n192.168.56.3 lfirstcitizens.wntps.com\n192.168.56.3 lgoldstarpayments.wntps.com\n192.168.56.3 payments-vantagegateway-com.wntps.com\n192.168.56.3 payments-gochipnow-com.wntps.com\n192.168.56.3 mobilepayments-jncb-com.wntps.com\n192.168.56.3 abacuspay-cmtgroup-com.wntps.com\n192.168.56.3 testpayments-itsco-net.wntps.com" >> /etc/hosts'
