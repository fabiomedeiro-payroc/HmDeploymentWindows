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
  DIR="$PWD/$1"
  COMMAND=$2
  echo $DIR
  if [ -e $DIR ]
  then
    $COMMAND $DIR
  else
    mkdir -p $DIR
    $COMMAND $DIR
  fi
}

echo "Downloading the Git and SVN readOnly Key"
wget https://github.com/fabioamedeiro/HmDeploymentWindows/raw/main/svn_readonly.zip -O $HOME/svn_readonly.zip  > /dev/null 2>&1
check_command

echo "Unziping the Git and SVN readOnly Key "
unzip $HOME/svn_readonly.zip
check_command 

echo "Creating .ssh Folder"
mkdir $HOME/.ssh

echo "Create $HOME/.ssh/conf"
printf "HOST soundwave.worldnettps.com\nUser svn_read_only\nHostname 35.242.179.51\nIdentityFile $HOME/svn_readonly\nForwardAgent yes\n\nHOST git.worldnettps.com\nUser gitro\nHostname 35.246.3.106\nIdentityFile $HOME/svn_readonly\nForwardAgent yes" > $HOME/.ssh/config
check_command

echo "Setting Read Only private Key Permission"
chmod 600 $HOME/svn_readonly
check_command

echo "Creating Nettraxion Folder"
if_dir_exist "payroc/workspace/nettraxion" "echo"

echo  "Cloning host-management"
if_dir_exist "payroc/workspace/host-management" "git clone git.worldnettps.com:/var/git/host-management" > /dev/null 2>&1

echo "Cloning host-management-binaries"
if_dir_exist "payroc/workspace/host-management-binaries" "git clone git.worldnettps.com:/var/git/host-management-binaries" > /dev/null 2>&1

echo "Cloning test-credentials"
if_dir_exist "payroc/workspace/test-credentials" "git clone git.worldnettps.com:/var/git/test-credentials" > /dev/null 2>&1

echo "Cloning service-simulator"
if_dir_exist "payroc/workspace/host-management/sources/service-simulator" "svn co svn+ssh://soundwave.worldnettps.com/etc/subversion/service-simulator" > /dev/null 2>&1

echo "Creating sources Dir to receive HM"
if_dir_exist "payroc/workspace/host-management" "cd"

echo "Creating Python Virtual environment for HM"
virtualenv .venv -p python3.9 >/dev/null 2>&1
check_command

echo "Activating Python Virtual Environment"
source  .venv/bin/activate >/dev/null 2>&1

echo "Deploying requirements.txt on Python Virtual Environment"
pip install -r requirements.txt
check_command

echo "Deploying requirements.yml on Python Virtual Environment"
ansible-galaxy install -r requirements.yml # >/dev/null 2>&1
check_command

echo "Making sure vagrant environment is loaded"
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Programs/Virtualbox"

echo "Deploying vkapp1, vkpmm1, vkpcx101 and vkweb1"
vagrant up >/dev/null 2>&1
check_command

echo "Setting right permission on vagrant vms private key"
chmod 600 inventory/vagrant/insecure_private_key.pem
check_command

echo "Creating inventory/vagrant/group_vars/all/ignore.yml with Maven test user"
printf "build_maven_username: 'wntest'\nbuild_maven_password: 'worldPass1'" > inventory/vagrant/group_vars/all/ignore.yml
check_command

echo "Making sure acl, python3-pexpect and patch are installed"
ansible all:!localhost -m shell -b -a "apt-get update; apt-get install acl python3-pexpect patch"
check_command

echo "Ping all vms "
ansible all -m ping   >/dev/null 2>&1
check_command

echo "Please, enter Nettraxion branch, which will be deployed: "
read NVERSION

echo "Cloning Nettraxion Branch $NVERSION"
svn co svn+ssh://soundwave.worldnettps.com/etc/subversion/server/branches/$NVERSION  ../nettraxion/$NVERSION > /dev/null 2>&1

echo "Define what branch will be deployed on payroc/workspace/host-management/inventory/vagrant/group_vars/all/versions.yml "
printf "nettraxion_debug: True\n# Branch to deploy\nbuild_nettraxion_version: "$NVERSION"\n# Workspace directory# Dont forget to replace <user> with your username.\nbuild_nettraxion_source_dir: "$PWD/../nettraxion"\nnettraxion_sources_dir: %s\"{{ build_nettraxion_source_dir }}/{{ build_nettraxion_version }}\"\nnettraxion_zip_remote_src: false\nnettraxion_ear_remote_src: false" > $PWD/inventory/vagrant/group_vars/all/versions.yml
check_command

read -p "Please, make sure you connected to Dublin VPN via OpenVpn. If you do not have access to it, p$NVERSION ulease contact the sysadmin team.IF you are connected please press any key to resume"

echo "Starting site.yml"
ansible-playbook site.yml

echo "Adding HM hosts on  /etc/hosts"
sudo -- sh -c 'grep vagrant.wntps.com /etc/hosts > /dev/null 2>1 ; if [ $? -eq 1 ]; then printf "\n# IP address of WEB server VM\n192.168.56.3 vagrant.wntps.com\n192.168.56.3 lcashflows.wntps.com\n192.168.56.3 lpayius.wntps.com\n192.168.56.3 lpayjack.wntps.com\n192.168.56.3 lpago.wntps.com\n192.168.56.3 lpivotal.wntps.com\n192.168.56.3 lanywherecom.wntps.com\n192.168.56.3 lctpayment.wntps.com\n192.168.56.3 lpayconex.wntps:w.com\n192.168.56.3 lpayzone.wntps.com\n192.168.56.3 lgoepay.wntps.com\n192.168.56.3 lfirstcitizens.wntps.com\n192.168.56.3 lgoldstarpayments.wntps.com\n192.168.56.3 payments-vantagegateway-com.wntps.com\n192.168.56.3 payments-gochipnow-com.wntps.com\n192.168.56.3 mobilepayments-jncb-com.wntps.com\n192.168.56.3 abacuspay-cmtgroup-com.wntps.com\n192.168.56.3 testpayments-itsco-net.wntps.com\n192.168.56.8 simulator.wntps.com\n192.168.56.8 sftp.wntps.com" >> /etc/hosts; fi'
check_command

echo "Remove $HOME/.ssh/conf"
rm  $HOME/.ssh/conf
check_command