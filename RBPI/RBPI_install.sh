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
echo "Access Point Installation"
read -p "To begin with the installation type in 'yes': " out
if ! [ "$out" = "yes" ]
then
  echo "Exiting..."
  exit 1
fi


# getting install paramenters from user
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "---- Access Point Configuration ----"
read -p "Enter the wireless interface used for the AP" wls_interface
read -p "Enter the SSID: " ap_ssid
read -p "Enter the password: " ap_pass

if [ "${ap_ssid}" ] && [ "${ap_pass}" ]
then
    echo "All variables correctly entered"
else
  echo "Empty variables. Exiting..."
  exit 1
fi
# showing available internet connections
nmcli device status
echo "---- Internet Access Configuration ----"
read -p "Enter the name of the modem interface: " mod_interface
echo "Starting..."


# preparing for install
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "${mod_interface} down for installation"
sudo ifconfig ${mod_interface} down
mon_errors
echo "Updating package sources..."
sudo apt-get update -y
sudo apt-get upgrade -y
mon_errors
echo "Installing hostapd dnsmasq"
sudo apt-get install hostapd -y
sudo apt-get install dnsmasq -y
sudo apt-get install bridge-utils -y
mon_errors
echo "Stopping hostapd and dnsmasq"
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
mon_errors


# Adding DHCP configuration
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Writing to /etc/dhcpcd.conf ..."
text="
interface ${wls_interface}
static ip_address=0.0.0.0/24
nohook wpa_supplicant"
sudo sh -c "echo '${text}'>>/etc/dhcpcd.conf"
sudo chmod 777 /etc/dhcpcd.conf
mon_errors


# DHCP Range config
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring dnsmasq"
echo "Writing to /etc/dnsmasq.conf ..."
text="
interface=${wls_interface}
dhcp-range=192.168.0.2,192.168.0.99,255.255.255.0,24h"
sudo sh -c "echo '${text}'>/etc/dnsmasq.conf"
sudo chmod 777 /etc/dnsmasq.conf
mon_errors


# WiFi Setup
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Configuring hostapd"
echo "Writing to /etc/hostapd/hostapd.conf ..."
text="
interface=${wls_interface}
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
ssid=${ap_ssid}
wpa_passphrase=${ap_pass}"
sudo sh -c "echo '${text}'>/etc/hostapd/hostapd.conf"
sudo chmod 777 /etc/hostapd/hostapd.conf
mon_errors
echo "Writing to /etc/default/hostapd..."
text="
DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""
sudo sh -c "echo '${text}'>/etc/default/hostapd"
sudo chmod 777 /etc/default/hostapd
mon_errors


# forwarding traffic from AP to active connection
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installing traffic forwarding"
echo "Appending to /etc/sysctl.conf..."
text="
net.ipv4.ip_forward=1"
sudo sh -c "echo '${text}'>>/etc/sysctl.conf"
mon_errors


# updating IP tables
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "add iptables rule"
sudo iptables -t nat -A POST -o ${mod_interface} -j MASQ
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
echo "Appending to /etc/rc.local..."
text="
iptables-restore < /etc/iptables.ipv4.nat
exit 0"
sudo sed -i '/exit 0/d'  /etc/rc.local
sudo sh -c "echo '${text}'>>/etc/rc.local"
sudo chown root:root /etc/rc.local
sudo chmod 777 /etc/rc.local


# Finishing up Installation
echo "${mod_interface} is up"
sudo ifconfig ${mod_interface} up
mon_errors
echo "hostapd and dnsmasq is up"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo systemctl start dnsmasq
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation is complete. Please reboot..."