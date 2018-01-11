#!/bin/bash

# SIGTERM-handler
term_handler() {
  echo "Get SIGTERM"
  iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
  /etc/init.d/dnsmasq stop
  /etc/init.d/hostapd stop
  /etc/init.d/dbus stop
  kill -TERM "$child" 2> /dev/null
}

#python /cam.py
#ls

ifconfig wlan0 10.0.0.1/24

if [ -z "$SSID" -a -z "$PASSWORD" ]; then
  ssid="Pi3-AP"
  password="raspberry"
else
  ssid=$SSID
  password=$PASSWORD
fi
sed -i "s/ssid=.*/ssid=$ssid/g" /etc/hostapd/hostapd.conf
sed -i "s/wpa_passphrase=.*/wpa_passphrase=$password/g" /etc/hostapd/hostapd.conf

/etc/init.d/dbus start
/etc/init.d/hostapd start
/etc/init.d/dnsmasq start
/etc/init.d/apache2 start
/etc/init.d/samba start

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE
if [ ! $? -eq 0 ]
then
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
fi

#usermod -a -G video $(whoami)
#chmod u+s /dev/vchiq
#chmod 777 /dev/vchiq
#tail /dev/vchiq
chmod a+rw /dev/vchiq
usermod -a -G video $(whoami)
usermod -a -G video root
usermod -a -G video www-data


# setup handlers
trap term_handler SIGTERM
trap term_handler SIGKILL

tail -f /var/log/apache2/error.log

#sleep infinity &
#child=$!
#wait "$child"