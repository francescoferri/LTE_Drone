#!/bin/bash
<<COMMENT
Useful Link: https://www.instructables.com/Raspberry-PI-3-Enable-Serial-Communications-to-Tty/
COMMENT

mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}

# begin
begin(){
    # asking for user confirmation
    read -p "To begin with the installation type in 'yes': " out
    if ! [ "$out" = "yes" ]
    then
        echo "Exiting..."
        exit 1
    fi
    # checking if ssh keys are present
    if ! test -f /home/pi/LTE_Drone/raspberrypi/*.pem
    then
        echo "SSH key absent in ~/LTE_Drone/raspberrypi/!!! Exiting..."
    fi
    # Ground Station ip and user request
    read -p "Insert the ground station's IP addres in the ZeroTier network: " gs_ip
    read -p "Insert the ground station's username: " gs_user
    if [ "${gs_ip}" ] && [ "${gs_user}" ]
    then
        echo "IP and user correctly entered"
    else
    echo "Empty variables. Exiting..."
    exit 1
    fi
}

prep() {
    sudo apt-get -y update
    sudo apt-get -y upgrade
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
}

mavlink_download(){
    #Download
    git clone https://github.com/intel/mavlink-router.git
    cd mavlink-router
    sudo git submodule update --init --recursive
    #Make and Compile
    sudo ./autogen.sh && sudo ./configure CFLAGS='-g -O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr
    sudo make
}

mavlink_configure() {

    if [ ! -d "/etc/mavlink-router" ] 
    then
        sudo mkdir /etc/mavlink-router
        sudo touch /etc/mavlink-router/main.conf
    fi

    cd /etc/mavlink-router
text="
# Mavlink-router serves on this TCP port
[General]
TcpServerPort=5790
ReportStats=false
MavlinkDialect=auto
FlowControl=true

# Raspberry Pi to Flight Controller connection
[UartEndpoint bravo]
Device = /dev/ttyAMA0
Baud = 921600,500000,115200,57600,38400,19200,9600
FlowControl=true"
    sudo sh -c "echo '${text}'>/etc/mavlink-router/main.conf"
    sudo chmod 777 main.conf
    echo "Wrote to /etc/mavlink-router/main.conf"
}

uart_configure() {

    #deleting default console on ttyAMA0
    sudo sed -i '/console=serial0,115200/d'  /boot/config.txt
    
    # enabling default uart port
    if grep -q enable_uart=1 /boot/config.txt; 
    then
    echo "enable_uart=1 present"
    else
    text="
enable_uart=1"
    sudo sh -c "echo '${text}'>>/boot/config.txt"
    echo "Appended to /boot/config.txt"
    fi

    # editing bluetooth config
    if grep -q dtoverlay=disable-bt /boot/config.txt; 
    then
    echo "dtoverlay present"
    else
    text="
dtoverlay=disable-bt"
    sudo sh -c "echo '${text}'>>/boot/config.txt"
    echo "Appended to /boot/config.txt"
    fi
}

rc_local(){
    # checking if rc.local has already been edited
    if grep -q "sudo -H -u pi /bin/bash -c /home/pi/LTE_Drone/raspberrypi/start_uav_services.sh" /etc/rc.local;
    then
    echo "rc.local already been edited. Continuing..."
    else
    # first remove the "exit 0" line
    sudo sed -i '/exit 0/d'  /etc/rc.local
    # append to rc.local
text='printf "---- Starting UAV services ---- \\n"
sudo -H -u pi /bin/bash -c /home/pi/LTE_Drone/raspberrypi/start_uav_services.sh #starts ssh and mavlink
dhcpcd -n # Notifies dhcpcd to reload its configuration at active interface
printf "---- Done starting UAV services ---- \\n"
exit 0'
    sudo sh -c "echo '${text}'>>/etc/rc.local"
    echo "Appended to /etc/rc.local"
    fi
    #permissions
    sudo chown root:root /etc/rc.local
    sudo chmod 777 /etc/rc.local
}

configure_groundstation(){
    sed -i "s/GSIP/$gs_ip/g" /home/pi/LTE_Drone/raspberrypi/start_uav_services.sh
    sed -i "s/GSUSER/$gs_user/g" /home/pi/LTE_Drone/raspberrypi/start_uav_services.sh

}

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "---- MAVLink Installation ----"
begin
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing packages..."
prep
mon_errors
echo "Done installing packages..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading MAVLink..."
mavlink_download
mon_errors
echo "Done Downloading MAVLink..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring MAVLink..."
mavlink_configure
mon_errors
echo "Done Configuring MAVLink..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring UART port ttyS0..."
uart_configure
mon_errors
echo "Done Configuring UART port..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring rc.local for autostart on boot..."
rc_local
mon_errors
echo "Done Configuring rc.local..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring the ground station IP..."
configure_groundstation
mon_errors
echo "Done Configuring IP..."
echo "Done. Please reboot your pi"
