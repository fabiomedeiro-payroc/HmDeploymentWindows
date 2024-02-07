#!/bin/bash
check_command()
{
 if [ $? -eq 0 ]
 then
   echo "Done"
   echo ""
 else
   echo "Error"
   exit 1
 fi
}
if_dir_exist()
{
  DIR="$HOME/$1"
  COMMAND=$2
  if [ -e $DIR ]
  then
    $COMMAND $DIR
  else
    mkdir -p $DIR
    $COMMAND $DIR
  fi
}

echo "Adding repository for python 3.9"
sudo add-apt-repository --yes ppa:deadsnakes/ppa > /dev/null 2>&1
check_command

echo "Adding repository for vagrant "
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
check_command

echo "Update Ubuntu cache and upgrade packages"
sudo apt update -y
check_command

echo "Upgrading Ubuntu packages"
sudo apt-get upgrade -y > /dev/null 2>&1
check_command

echo "Upgrade packages"
sudo apt  --with-new-pkgs upgrade -y
check_command


echo "Installing python3.9"
sudo apt-get install python3.9 python3.9-distutils -y > /dev/null 2>&1
check_command

echo "Installing sshpass, git, subversion, vagrant  and virtualbox"
sudo apt-get install sshpass git subversion vagrant vim  unzip -y > /dev/null 2>&1
check_command

echo "Installing pip"
sudo apt-get install python3-pip -y > /dev/null 2>&1
check_command

echo "Installing virtualenv"
sudo python3.9 -m pip install virtualenv > /dev/null 2>&1
check_command

echo "Installing Ansible"
sudo python3.9 -m pip install ansible==5.10.0 > /dev/null 2>&1
check_command

echo "Installing Maven"
sudo apt-get install maven -y > /dev/null 2>&1
check_command

echo "Setting metadata on WSL"
sudo sh -c 'printf "[automount]\noptions = "metadata"\n[network]\ngenerateResolvConf = false " > /etc/wsl.conf'


echo "Setting Google DNS to resolv.conf "
sudo sh -c 'rm  /etc/resolv.conf; printf "nameserver 8.8.8.8" > /etc/resolv.conf'
check_command

echo "Setting JAVA "
sh -c 'grep -ri JAVA_HOME $HOME/.bashrc > /dev/null 2>1 ; if [ $? -eq 1 ]; then printf "JAVA_HOME=$HOME/custom_java/jdk8\nJRE_HOME=$HOME/custom_java/jdk8/jre\nPATH=\"$HOME/custom_java/jdk8/bin:$PATH:/mnt/c/Program Files/Oracle/VirtualBox\"" >> $HOME/.bashrc; fi'
check_command

echo "Setting Windows VirtualBox Access"
sh -c 'grep VAGRANT_WSL_ENABLE_WINDOWS_ACCESS $HOME/.bashrc > /dev/null 2>1 ; if [ $? -eq 1 ]; then printf "\nVAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"" >> $HOME/.bashrc; fi'
check_command

echo "Making sure the Windows VirtualBox Access by vagrant"
sudo sh -c 'grep VAGRANT_WSL_ENABLE_WINDOWS_ACCESS  /usr/bin/vagrant > /dev/null 2>1 ; if [ $? -eq 1 ]; then sed -i "/^\/opt\/vagrant.*/i export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"" /usr/bin/vagrant; fi'
check_command

echo "Activating Java and virtualbox settings"
source $HOME/.bashrc

echo "Downloading NVM"
wget -P $HOME https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh ; bash $HOME/install.sh; source $HOME/.nvm/nvm.sh

echo "Installing Node"
nvm install --lts
check_command

echo "Installing WN CLI"
npm install --global worldnet-cli
check_command

echo "Checking the version of vagrant"
VAGRANT_VERSION=`vagrant --version | awk '{ print $2 }'`

echo "Enabling EXTsudo sed -i 's/if info \&\& (info\[:type\] == "drvfs" || info\[:type\] == "9p")/if info \&\& (info\[:type\] == "drvfs" || info\[:type\] == "9p" || info\[:type\] == "ext4")/g'  /opt/vagrant/embedded/gems/gems/vagrant-$VAGRANT_VERSION/lib/vagrant/util/platform.rb4 support to vagrant"

