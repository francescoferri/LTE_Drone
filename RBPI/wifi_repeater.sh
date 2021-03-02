<<COMMENT
This file is used to
- connect a wifi dongle to a network
- set up an access point using the PI's onboard wifi interface
Useful links:
https://www.electronicshub.org/setup-wifi-raspberry-pi-2-using-usb-dongle/
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
    sudo iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -t nat -I POSTROUTING -o eth1 -j MASQUERADE
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
