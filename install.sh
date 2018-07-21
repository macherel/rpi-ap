#!/bin/bash

################################################################
## Update Raspbian
################################################################
sudo apt-get update
sudo apt-get upgrade

################################################################
## Install Wifi AP stuff
################################################################
sudo apt-get install -y dnsmasq hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd
sudo tee -a /etc/dhcpcd.conf > /dev/null << EOF
interface wlan0
	static ip_address=192.168.4.1/24
EOF
sudo service dhcpcd restart
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo tee /etc/dnsmasq.conf > /dev/null << EOF
interface=wlan0	# Use the require wireless interface - usually wlan0
	dhcp-range=192.168.4.10,192.168.4.200,255.255.255.0,12h
EOF
sudo tee /etc/hostapd/hostapd.conf > /dev/null << EOF
interface=wlan0
driver=nl80211
ssid=MAP
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=GeriVIaD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
sudo tee -a /etc/default/hostapd > /dev/null << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
sudo service hostapd start
sudo service dnsmasq start
sudo sed -rie 's/#(net.ipv4.ip_forward=1)/\1/' /etc/sysctl.conf
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
sudo iptables-restore < /etc/iptables.ipv4.nat

################################################################
## Install web server
################################################################
sudo apt-get install -y apache2

################################################################
## reboot
################################################################
sudo reboot
