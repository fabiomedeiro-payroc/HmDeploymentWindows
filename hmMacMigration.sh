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

read -p "Please, make sure you have copied your private ssh keys for git and svn.IF so,please press any key to resume"



echo "Creating Nettraxion Folder"
if_dir_exist "payroc/workspace/nettraxion" "echo"

echo  "Cloning host-management"
if_dir_exist "payroc/workspace/host-management" "git clone git.worldnettps.com:/var/git/host-management" > /dev/null 2>&1

echo "Cloning host-management-binaries"
if_dir_exist "payroc/workspace/host-management-binaries" "git clone git.worldnettps.com:/var/git/host-management-binaries" > /dev/null 2>&1

echo " change to the branch r_10.2.0.0_hm_on_mac"
cd payroc/workspace/host-management-binaries
git checkout branch r_10.2.0.0_hm_on_mac
cd $HOME
check_command

echo "Cloning test-credentials"
if_dir_exist "payroc/workspace/test-credentials" "git clone git.worldnettps.com:/var/git/test-credentials" > /dev/null 2>&1

echo "Cloning service-simulator"
if_dir_exist "payroc/workspace/host-management/sources/service-simulator" "svn co svn+ssh://soundwave.worldnettps.com/etc/subversion/service-simulator" > /dev/null 2>&1

echo "Creating sources Dir to receive HM"
if_dir_exist "payroc/workspace/host-management" "cd"

echo " change to the branch r_10.2.0.0_hm_on_mac"
git checkout branch r_10.2.0.0_hm_on_mac
check_command

echo "Deploying the virtualenv"
/opt/homebrew/bin/python3.9 -m pip install virtualenv
check_command

echo "Creating Python Virtual environment for HM"
/opt/homebrew/bin/python3.9 -m virtualenv .venv -p python3.9 >/dev/null 2>&1
check_command

echo "Activating Python Virtual Environment"
source  .venv/bin/activate >/dev/null 2>&1

echo "Deploying requirements.txt on Python Virtual Environment"
pip install -r requirements.txt >/dev/null 2>&1
check_command

echo "Deploying requirements.yml on Python Virtual Environment"
ansible-galaxy install -r requirements.yml  >/dev/null 2>&1
check_command


echo "Deploying vkapp1, vkpmm1, vkpcx101 and vkweb1"
vagrant up >/dev/null 2>&1


echo "Setting right permission on vagrant vms private key"
chmod 600 inventory/vagrant/insecure_private_key.pem
check_command

echo "Creating inventory/vagrant/group_vars/all/ignore.yml with Maven test user"
printf "build_maven_username: 'wntest'\nbuild_maven_password: 'worldPass1'" > inventory/vagrant/group_vars/all/ignore.yml
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

read -p "Please, make sure you connected to Dublin VPN via OpenVpn. If you do not have access to it, please contact the sysadmin team.IF you are connected please press any key to resume"

echo "Starting site.yml"
ansible-playbook site.yml

echo "Remove $HOME/.ssh/config"
rm  $HOME/.ssh/config
check_command
