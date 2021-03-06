#!/bin/bash
<<COMMENT
This file is used to
- connect a wifi dongle to a network
- set up an access point using the PI's onboard wifi interface
Useful links:
https://www.raspberrypi.org/forums/viewtopic.php?t=132674
https://www.electronicshub.org/setup-wifi-raspberry-pi-2-using-usb-dongle/
extra links:
https://raspberrypi.stackexchange.com/questions/39227/rpi-as-internet-gateway-bridge/39240#39240
COMMENT

mon_errors() {
  if ! [ $? = 0 ]
  then
    echo "An error occured! Aborting...."
    exit 1
  fi
}


get_info() {
  echo "This script will turn your RBPI into a WiFi Bridge"
  echo "The RBPI will forward information between two wireless interfaces. Let's begin..."
  
  echo "Let's start with the network connection..."
  read -p "Insert the SSID of the network you want to connect to: " net_ssid
  read -p "Insert the PASSWORD of the network you want to connect to: " net_pws
  read -p "Insert the name of the interface you want to use to connect to the network: " net_int

  echo "Now your hotspot connection..."
  read -p "Insert the hotspot's SSID: " my_ssid
  read -p "Insert the hotspot's PASSWORD: " my_pw
  read -p "Insert the name of the interface you want to use for your hotspot: " my_int
}


prep() {
  #sudo ifconfig eth0 down
  echo "Updating..."
  sudo apt-get update -y
  sudo apt-get upgrade -y
  mon_errors
  echo "Done updating."
  echo "Installing hostapd, dnsmasq and bridge-utils"
  sudo apt-get install hostapd -y
  sudo apt-get install dnsmasq -y
  sudo apt-get install bridge-utils -y
  mon_errors
  echo "Done installing hostapd, dnsmasq and bridge-utils."
  echo "Stopping hostapd and dnsmasq for installation..."
  sudo systemctl stop hostapd
  sudo systemctl stop dnsmasq
  mon_errors
  echo "Done preparing."
}


dhcp_func() {
  echo "Editing /etc/dhcpcd.conf ..."
  text="
interface ${my_int}
static ip_address=192.168.0.1/24
nohook wpa_supplicant
#denyinterfaces ${net_int}
#denyinterfaces ${my_int}
  "
  sudo sh -c "echo '$text'>>/etc/dhcpcd.conf"
  sudo chmod 777 /etc/dhcpcd.conf
  mon_errors
  echo "Done editing /etc/dhcpcd.conf"
}


dnsmasq_func() {
  echo "Editing /etc/dnsmasq.conf ..."
  # backup old file
  sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
  text="
interface=wlan0
dhcp-range=192.168.0.2,192.168.0.99,255.255.255.0,24h
  "
  sudo sh -c "echo '$text'>/etc/dnsmasq.conf"
  sudo chmod 777 /etc/dnsmasq.conf
  mon_errors
  echo "Done editing /etc/dnsmasq.conf"
}


hostapd_func() {
  echo "Editing /etc/hostapd/hostapd.conf ..."
  text="
interface=${my_int}
driver=nl80211
#bridge=br0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=${my_ssid}
wpa_passphrase=${my_pw}
  "
  sudo sh -c "echo '$text'>/etc/hostapd/hostapd.conf"
  sudo chmod 777 /etc/hostapd/hostapd.conf
  mon_errors
  echo "Done editing /etc/hostapd/hostapd.conf"
  echo "Editing /etc/default/hostapd..."
  text="
DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"
  "
  sudo sh -c "echo '$text'>/etc/default/hostapd"
  sudo chmod 777 /etc/default/hostapd
  mon_errors
  echo "Done editing /etc/default/hostapd"
}


interfaces(){ 
    echo "Editing /etc/network/interfaces"
    text="
auto lo
iface lo inet loopback
iface ${net_int} inet manual

auto ${my_int}
allow-hotplug ${my_int}
iface ${my_int} inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    "
    sudo sh -c "echo '${text}'>/etc/network/interfaces"
    #sudo chmod 777 /etc/network/interfaces
    echo "Done editing /etc/network/interfaces"
}


wpa_supplicant(){
    
    echo "Editing wpa_supplicant.conf"
    echo "Appending to /etc/wpa_supplicant/wpa_supplicant.conf"
    text="
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CA

network={
    ssid=”${net_ssid}”
    psk=”${net_pws}”
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP TKIP
    group=CCMP TKIP
    id_str=”${net_ssid}”
}
    "
    sudo sh -c "echo '${text}'>/etc/wpa_supplicant/wpa_supplicant.conf"
    #sudo chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
}


forwarding(){
    sudo iptables -X
    sudo iptables -F
    sudo iptables -t nat -X
    sudo iptables -t nat -F
    sudo sh -c "echo 'net.ipv4.ip_forward=1'>>/etc/sysctl.conf"
    sudo iptables -t nat -A POSTROUTING -o ${net_int} -j MASQUERADE #adding ip table for forwarding interface
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat" #saving configuration to iptab...
    sudo touch /lib/dhcpcd/dhcpcd-hooks/70-ipv4-nat
    sudo sh -c "echo 'iptables-restore < /etc/iptables.ipv4.nat'>>/etc/sysctl.conf"
    sudo sh -c "echo 'nameserver 208.67.222.222'>>/etc/resolv.conf" #adding a dns server
}


finish() {
  echo "Bringing ${net_int} back up..."
  sudo ifconfig ${net_int} up
  mon_errors
  echo "Brought ${net_int} back up..."

  echo "Bring hostapd and dnsmasq back up..."
  sudo systemctl unmask hostapd
  sudo systemctl enable hostapd
  sudo systemctl start hostapd
  sudo systemctl start dnsmasq
  mon_errors
  echo "Brought hostapd and dnsmasq back up..."
}


# begin
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WiFi Repeater Installation:"
read -p "To begin with the installation type 'yes': " out
if ! [ "$out" = "yes" ]
then
  echo "Exiting..."
  exit 1
fi


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
get_info
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Preparing for installation..."
prep
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
ehco "Configuring DHCP..."
dhcp_func
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring DNS mask..."
dnsmasq_func
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring hostapd..."
hostapd_func
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Updating interfaces."
interfaces
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Editing wpa_supplicant."
wpa_supplicant
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Flushing and updating iptables"
forwarding
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finishing up now..."
finish
mon_errors
echo "Installation complete, please reboot your PI. Rebooting..."
sudo sleep 10
sudo reboot now
