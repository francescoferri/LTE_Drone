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


#Configure mavlink router
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuration: mavlink data stream on localhost port 5678 TCP"                                                                                             
if [ ! -d "/etc/mavlink-router" ] 
then
    echo "Directory /etc/mavlink-router does not exist. Making it." 
    sudo mkdir /etc/mavlink-router
    echo "Made /etc/mavlink-router" 
fi
cd /etc/mavlink-router
sudo chmod 777 main.conf
echo "Done configuring mavlink-router..."
mon_errors


# download mavlink start scripts
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Now download the autostart scripts for mavlink-router"
if [ ! -d "/home/ubuntu/startupscripts" ] 
then
    echo "Directory /home/ubuntu/startupscripts does not exist yet. Making it." 
    sudo -u ubuntu mkdir /home/ubuntu/startupscripts
    echo "Made /home/ubuntu/startupscripts" 
fi
cd /home/ubuntu/startupscripts
sudo chmod 777 /home/ubuntu/startupscripts/start_mavlinkrouter.sh
sudo chmod 777 /home/ubuntu/startupscripts/autostart_mavlinkrouter.sh
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