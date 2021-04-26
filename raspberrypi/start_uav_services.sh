#!/bin/bash

# Start Mavlink Router using main.conf
text="/home/pi/mavlink-router/mavlink-routerd"
screen -L -d -m -S "MAVLink_Router" -s /bin/bash $text

# Autossh with server Ground Station
text='autossh -N -R 5790:localhost:5790 -i "/home/pi/LTE_Drone/raspberrypi/KEY.pem" GSUSER@GSIP'
screen -L -d -m -S "MAVLink_SSH_Tunnel" -s /bin/bash $text

# Autostart terminal to Ground Station
text='autossh -N -R 6000:localhost:22 -i "/home/pi/LTE_Drone/raspberrypi/KEY.pem" GSUSER@GSIP'
screen -L -d -m -S "Terminal_SSH_Tunnel" -s /bin/bash $text

# Webcam
