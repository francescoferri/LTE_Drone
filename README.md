# LTE_Drone

This project connects a Raspberry Pi to the internet using a 4G LTE Modem. The Pi is used as a companion computer, connected to an onboard flight controller running autopilot software such as Arduplane.

## About

### Hardware

- Raspberry Pi - any model should work, the Pi Zero W was used in this project
- 4G LTE Module - [Huawei E3372](https://www.amazon.it/Huawei-E3372h-153-Router-MBps-Dongle/dp/B013UURTL4/ref=sr_1_2?crid=L70HJQ20R5I0&dchild=1&keywords=huawei+e3372+modem&qid=1618542368&sprefix=Huawei+E3372%2Caps%2C238&sr=8-2) was used in this project
- SIM card - with activated internet connection
- USB adapters - in case you are using a Pi Zero W
- Flight Controller - [Omnibus F4 Pro](https://www.banggood.com/Original-Airbot-Omnibus-F4-Pro-V3-Flight-controller-SD-5V-3A-BEC-OSD-Current-Sensor-LC-Filter-for-X-Class-p-1319177.html?cur_warehouse=CN&rmmds=search) was used in this project
- Logic Level Converter - [LLC](https://www.banggood.com/10Pcs-Logic-Level-Converter-Bi-Directional-IIC-4-Way-Level-Conversion-Module-p-1033750.html?cur_warehouse=CN&rmmds=search) this is used to connect UART interfaces between Flight Controller and Pi

### Software

- Latest version of Raspian (project built on Buster)
- Arduplane already installed on the Flight Controller

## Getting Started

### Installation

Prerequisites:

- Ensure your Pi is connected to the internet via ethernet or WiFi.
- Log into the Pi as user "pi" either with SSH or Desktop GUI.
- The working folder should be /home/pi
- Modem is unplugged from the Pi.
- ZeroTier account, with a network already created and its relative ID ready for input.

1. Start by cloning this repo into the Pi's home folder.

```bash
cd
git clone https://github.com/francescoferri/LTE_Drone ~/LTE_Drone
```

2. Plug your modem into your Pi and run:

```bash
ifconfig
```

Take note of the onboard WiFi interface (default: wlan0) and the modem's interface (default: eth0 on Pi Zero W).

3. Unplug the modem from the Pi.

4. Install ZeroTier by running:

```bash
sudo ~/LTE_Drone/raspberrypi/zerotier_install.sh
```

5. Install the Pi's access point by running:

```bash
sudo ~/LTE_Drone/raspberrypi/ap_install.sh
```

You should now be done. The Pi can either be accessed by connecting to the onboard WiFi, or through the ZeroTier VPN. This setup has a latency that ranges between 150 to 1000 milliseconds. However, I am planning to finish the AWS Ubuntu Server deployment, which will run much faster. Will also add a script to install the serial connection between FC and Pi. Enjoy and safe flying!
