#!/bin/bash

# This file is used in case you want to first install all packages prior to configuration.
# It is useful if you want to install this stuff before hooking up your modem. That way
# you save your data.

## Function Declaration
mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}

install_pkg_ap_install() {
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install hostapd -y
    sudo apt-get install dnsmasq -y
    sudo apt-get install bridge-utils -y
}

install_pkg_mavlink_install() {
    sudo apt-get -y install screen
    sudo apt-get -y install tcptrack
    sudo apt-get -y install libxml2-dev
    sudo apt-get -y install libxslt-dev
    sudo apt-get -y install python
    sudo apt-get -y install python-matplotlib
    sudo apt-get -y install python3
    sudo apt-get -y install python3-matplotlib
    sudo apt-get -y install python3-pip
    sudo apt-get -y install python3-numpy
    sudo apt-get -y install python3-dev
    sudo apt-get -y install python3-lxml
    sudo apt-get -y install python3-setuptools
    sudo apt-get -y install python3-genshi
    sudo apt-get -y install python3-lxml-dbg
    sudo apt-get -y install python-lxml-doc
    sudo apt-get -y install python-opencv
    sudo apt-get -y install python-pip
    sudo apt-get -y install python-numpy
    sudo apt-get -y install python-dev
    sudo apt-get -y install python-lxml
    sudo apt-get -y install python-setuptools
    sudo apt-get -y install git
    sudo apt-get -y install dh-autoreconf
    sudo apt-get -y install systemd
    sudo apt-get -y install wget
    sudo apt-get -y install emacs #might have to run twice
    sudo apt-get -y install nload
    sudo apt-get -y install build-essential
    sudo apt-get -y install autossh
    sudo pip install future
    sudo pip install pymavlink
    sudo pip install mavproxy
    sudo pip3 install future
    sudo pip3 install pymavlink
    sudo pip3 install mavproxy
    #Download MAVLink
    git clone https://github.com/intel/mavlink-router.git
    cd mavlink-router
    sudo git submodule update --init --recursive
    #Make and Compile
    sudo ./autogen.sh && sudo ./configure CFLAGS='-g -O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr
    sudo make
}

install_pkg_zerotier_install() {
   curl -s https://install.zerotier.com | sudo bash
}

## Beginning script here
echo "---- Installing Packages ----"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing for ap_install.sh"
install_pkg_ap_install
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing for mavlink..."
install_pkg_mavlink_install
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing for ZeroTier..."
install_pkg_zerotier_install
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Done installing packages. You can procede with the rest of the installation..."
