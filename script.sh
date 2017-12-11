#!/bin/bash
run_time=`date +%Y%m%d%H%M`


sudo apt-get update
#sudo apt-get dist-upgrade
sudo apt-get install -y dnsmasq hostapd


#################


echo "Setting interfaces"

echo "enyinterfaces wlan0" > /etc/dhcpcd.conf #needs to be echo'd somewhere

echo "source-directory /etc/network/interfaces.d" > /etc/network/interfaces
echo "auto lo"  >>  /etc/network/interfaces
echo "iface lo inet loopback"  >>  /etc/network/interfaces
echo "iface eth0 inet manual"  >>  /etc/network/interfaces
echo "allow-hotplug wlan0"  >>  /etc/network/interfaces
echo "iface wlan0 inet manual"  >>  /etc/network/interfaces
echo "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"  >>  /etc/network/interfaces

#################

echo "Restarting dhcpcd"

sudo service dhcpcd restart
sudo ifdown wlan0; sudo ifup wlan0

#################

echo "Setting up Hostapd"

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" > /etc/default/hostapd

# This is the name of the WiFi interface we configured above
echo "interface=wlan0" >  /etc/hostapd/hostapd.conf

# Use the nl80211 driver with the brcmfmac driver
echo "driver=nl80211" >>  /etc/hostapd/hostapd.conf

# This is the name of the network
echo "ssid=Pi3-AP" >>  /etc/hostapd/hostapd.conf

# Use the 2.4GHz band
echo "hw_mode=g" >>  /etc/hostapd/hostapd.conf

# Use channel 6
echo "channel=6" >>  /etc/hostapd/hostapd.conf

# Enable 802.11n
echo "ieee80211n=1" >>  /etc/hostapd/hostapd.conf

# Enable WMM
echo "wmm_enabled=1" >>  /etc/hostapd/hostapd.conf

# Enable 40MHz channels with 20ns guard interval
echo "ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]" >>  /etc/hostapd/hostapd.conf

# Accept all MAC addresses
echo "macaddr_acl=0" >>  /etc/hostapd/hostapd.conf

# Use WPA authentication
echo "auth_algs=1" >>  /etc/hostapd/hostapd.conf

# Require clients to know the network name
echo "ignore_broadcast_ssid=0" >>  /etc/hostapd/hostapd.conf

# Use WPA2
echo "wpa=2" >>  /etc/hostapd/hostapd.conf

# Use a pre-shared key
echo "wpa_key_mgmt=WPA-PSK" >>  /etc/hostapd/hostapd.conf

# The network passphrase
echo "wpa_passphrase=raspberry" >>  /etc/hostapd/hostapd.conf

# Use AES, instead of TKIP
echo "rsn_pairwise=CCMP" >>  /etc/hostapd/hostapd.conf

#################

echo "Setting up DNSMASQ"

echo "interface=wlan0" >  /etc/dnsmasq.conf        # Use interface wlan0
echo "listen-address=172.24.1.1" >>  /etc/dnsmasq.conf  # Explicitly specify the address to listen on
echo "bind-interfaces" >>  /etc/dnsmasq.conf      # Bind to the interface to make sure we aren't sending things elsewhere
echo "server=8.8.8.8" >>  /etc/dnsmasq.conf       # Forward DNS requests to Google DNS
echo "domain-needed" >>  /etc/dnsmasq.conf        # Don't forward short names
echo "bogus-priv" >>  /etc/dnsmasq.conf           # Never forward addresses in the non-routed address spaces.
echo "dhcp-range=172.24.1.50,172.24.1.150,12h" >>  /etc/dnsmasq.conf # Assign IP addresses between 172.24.1.50 and 172.24.1.150 with a 12 hour lease time

#################

echo "Setting up sysctl"
echo "net.ipv4.ip_forward=1"                             >> /etc/sysctl.conf
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

#################

echo "Setting up iptables"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"


#################

echo "starting services"

sudo service hostapd start
sudo service dnsmasq start

echo "done"

exit 0