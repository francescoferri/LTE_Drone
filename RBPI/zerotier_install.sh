#!/bin/bash

# checking for errors
mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}

# begin
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "ZeroTier Installation"
read -p "To begin with the installation type in 'yes': " out
if ! [ "$out" = "yes" ]
then
  echo "Exiting..."
  exit 1
fi

# getting install paramenters from user
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "---- ZeroTier Configuration ----"
read -p "Enter the ZeroTier network you would like to join: " zt_net
read -p "Enable autostart on boot? (default:y) [y/n] " autostart

if [ "${zt_net}" ] && [ "${autostart}" ]
then
    echo "All variables correctly entered"
else
  echo "Empty variables. Exiting..."
  exit 1
fi

#download zerotier
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading ZeroTier"
curl -s https://install.zerotier.com | sudo bash
mon_errors

#check installation
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation Status:"
sudo zerotier-cli status
mon_errors

#autostart
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Autostart Setting"
if [ ${autostart} == "y" ]
then
    sudo systemctl enable zerotier-one
    echo "Autostart on boot enabled!"
else
  echo "Autostart on boot disabled"
  exit 1
fi

#join zerotier network
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Joining ZeroTier network: ${zt_net}"
sudo zerotier-cli join ${zt_net}
mon_errors

#asking user for authentication
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Please, authorize the join request on ZeroTier Web UI..."

#displaying useful information
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "ifconfig output: "
ifconfig
echo " ^^^ The ZeroTier interface should be listed above, and begins with <zt> ^^^"
#done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation Complete. Exiting..."
