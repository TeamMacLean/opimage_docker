FROM sdhibit/rpi-raspbian:jessie
#FROM ubuntu:17.10
#FROM ubuntu:latest
MAINTAINER Martin Page

RUN apt-get update --fix-missing
RUN apt-get install -y hostapd dbus net-tools iptables dnsmasq vim
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

Add entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

#TODO cleanup: docker rmi $(docker images -q -f dangling=true)