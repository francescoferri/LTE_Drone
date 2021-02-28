#!/bin/bash

<<COMMENT
List of files to modify
- autostart_mavlink
- start_mavlink
- rc.local
add: sudo -H -u ubuntu /bin/bash -c '/home/ubuntu/startupscripts/autostart_mavlink.sh
to force the server to run it at startup

COMMENT

set -x

# checking for errors
mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing packages..."
sudo apt-get -y update                            
sudo apt-get -y upgrade
sudo apt-get -y install screen
sudo apt-get -y install tcptrack
sudo apt-get -y install python 
sudo apt-get -y install python-wxgtk2.8 
sudo apt-get -y install python-matplotlib  
sudo apt-get -y install python-opencv 
sudo apt-get -y install python-numpy  
sudo apt-get -y install python-dev 
sudo apt-get -y install libxslt-dev
sudo apt-get -y install python-lxml
sudo apt-get -y install python-setuptools
sudo apt-get -y install python3 
sudo apt-get -y install python3-matplotlib                                                                                          
sudo apt-get -y install python3-opencv                                                                                        
sudo apt-get -y install python3-pip                                                                                            
sudo apt-get -y install python3-numpy                                                                                         
sudo apt-get -y install python3-dev                                                                                            
sudo apt-get -y install git 
sudo apt-get -y install dh-autoreconf
sudo apt-get -y install systemd 
sudo apt-get -y install wget 
sudo apt-get -y install emacs                                            
sudo apt-get -y install emacs                                              
sudo apt-get -y install nload                                         
sudo apt-get -y install build-essential 
sudo apt-get -y install autossh 
sudo pip install future 
sudo pip install pymavlink 
sudo pip install mavproxy 
sudo pip3 install future                                                                                                       
sudo pip3 install pymavlink                                                                                                
sudo pip3 install mavproxy
mon_errors


# Downloading mavlink repo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading git clone"                                                                                      
git clone https://github.com/intel/mavlink-router.git
cd mavlink-router
sudo git submodule update --init --recursive
echo "Start making / compiling / building mavlink-router..."
sudo ./autogen.sh && sudo ./configure CFLAGS='-g -O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr --disable-systemd
sudo make
mon_errors


#Configure autostart mavlink router, add download to auto_mav and start_mav
sudo systemctl enable mavlink-router
sudo systemctl start mavlink-router
mon_errors


# rc.local to be finished
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading /etc/rc.local"
# Need to add filepath with wget once done
sudo chmod 777 /etc/rc.local
echo "Downloaded /etc/rc.local"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
sudo chmod 777 /etc/ssh/sshd_config
mon_errors


echo "Installation Complete. Exiting..."