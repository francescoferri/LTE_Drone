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


interfaces(){
    read "Insert the name of the dongle interface: " dongle_int
    read "Insert the name of the PI's onboard interface: " onboard_int
    echo "Editing Interfaces..."
    echo "Appending to /etc/network/interfaces"
    text="
    auto lo
    iface lo inet loopback
    iface ${dongle_int} inet manual

    auto ${onboard_int}
    allow-hotplug ${onboard_int}
    iface ${onboard_int} inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    "
    sudo sh -c "echo '${text}'>/etc/network/interfaces"
    #sudo chmod 777 /etc/network/interfaces
}


wpa_supplicant(){
    read "Insert the network's SSID: " my_ssid
    read "Insert the network's PASSWORD: " my_psk
    echo "Editing wpa_supplicant.conf"
    echo "Appending to /etc/wpa_supplicant/wpa_supplicant.conf"
    text="
    network={
        ssid=”${my_ssid}”
        psk=”${my_psk}”
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP TKIP
        group=CCMP TKIP
        id_str=”${my_ssid}”
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
    sudo nano /etc/sysctl.conf
    sudo sh -c "echo 'net.ipv4.ip_forward=1'>/etc/sysctl.conf"
    read "Insert the name of the dongle interface: " dongle_int
    sudo iptables -t nat -A POSTROUTING -o ${dongle_int} -j MASQUERADE #adding ip table for forwarding interface
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat" #saving configuration to iptab...
    sudo touch /lib/dhcpcd/dhcpcd-hooks/70-ipv4-nat
    sudo sh -c "echo 'iptables-restore < /etc/iptables.ipv4.nat'>/etc/sysctl.conf"
    sudo sh -c "echo 'nameserver 208.67.222.222' > /etc/resolv.conf" #adding a dns server
}


# begin
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Access Point-Dongle Installation"
read -p "To begin with the installation type in 'yes': " out
if ! [ "$out" = "yes" ]
then
  echo "Exiting..."
  exit 1
fi


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
iptables
mon_errors
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation complete, please reboot your PI. Exiting..."
