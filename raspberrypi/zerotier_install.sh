#!/bin/bash

## Function Declaration
# checking for errors
mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}

begin(){
  read -p "To begin with the installation type in 'yes': " out
  if ! [ "$out" = "yes" ]
  then
    echo "Exiting..."
    exit 1
  fi
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
}

#download zerotier
install_pkg(){
  curl -s https://install.zerotier.com | sudo bash
}

configure_zerotier(){
  if [ ${autostart} == "y" ]
  then
    sudo systemctl enable zerotier-one
    echo "Autostart on boot enabled!"
  else
    echo "Autostart on boot disabled"
  fi
  echo "Joining ZeroTier network: ${zt_net}"
  sudo zerotier-cli join ${zt_net}
  #asking user for authentication via Web UI
  read -p "Please, authorize the join request on ZeroTier Web UI. Press ENTER to continue..." useless
  echo "Initializing connection..."
  sleep 10s #sleeping to allow zerotier to update
  echo "Connection status: "
  sudo zerotier-cli info
  echo "This is your ip in the ZeroTier network: "
  sudo zerotier-cli get ${zt_net} ip
}

## Starting Installation here
echo "---- ZeroTier Installation ----"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Beginning..."
begin
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading ZeroTier"
install_pkg
mon_errors
echo "Done downloading ZeroTier"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring ZeroTier..."
configure_zerotier
mon_errors
echo "Done configuring ZeroTier..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation Complete. Exiting..."
