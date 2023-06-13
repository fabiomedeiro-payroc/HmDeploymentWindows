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
sudo apt-get install sshpass git subversion vagrant vim   -y > /dev/null 2>&1
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
printf "[automount]\noptions = "metadata"" > /etc/wsl.conf

echo "Setting JAVA "
sh -c 'grep -ri JAVA_HOME $HOME/.bashrc > /dev/null 2>1 ; if [ $? -eq 1 ]; then printf "JAVA_HOME=$HOME/custom_java/jdk8\nJRE_HOME=$HOME/custom_java/jdk8/jre\nPATH=\"$HOME/custom_java/jdk8/bin:$PATH:/mnt/c/Program Files/Oracle/VirtualBox\"" >> $HOME/.bashrc; fi'
check_command

echo "Setting Windows VirtualBox Access"
sh -c 'grep VAGRANT_WSL_ENABLE_WINDOWS_ACCESS $HOME/.bashrc > /dev/null 2>1 ; if [ $? -eq 1 ]; then printf "\nVAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"" >> $HOME/.bashrc; fi'
check_command

echo "Activating Java and virtualbox settings"
source $HOME/.bashrc