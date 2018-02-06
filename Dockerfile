FROM debian:stretch


MAINTAINER Martin Page

RUN apt-get update --fix-missing
RUN apt-get install -y build-essential zlib1g zlib1g-dev
RUN apt-get install -y hostapd dbus net-tools iptables dnsmasq
RUN apt-get install -y git python-dev python-pip python-setuptools python-wheel python-scipy python-matplotlib python-skimage cython python-tk python-picamera
RUN apt-get install -y apache2
RUN apt-get install -y samba
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

ADD smb.txt /
RUN (echo password; echo password) | smbpasswd -sa
RUN mkdir /data
RUN cat smb.txt >> /etc/samba/smb.conf
RUN rm smb.txt

RUN git clone git://github.com/TeamMacLean/opimage_things
RUN cd opimage_things; sudo python setup.py develop

RUN git clone git://github.com/TeamMacLean/opimage.git
RUN	cd opimage; sudo python setup.py develop

RUN rm -rf /var/www
RUN git clone git://github.com/wookoouk/opimage_interface.git /var/www
RUN chown www-data:www-data /var/www -R
RUN chmod 777 /var/www/cgi-bin/* -R
RUN adduser www-data dialout
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod cgi

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

RUN /etc/init.d/dbus stop
RUN /etc/init.d/hostapd stop
RUN /etc/init.d/dnsmasq stop
RUN /etc/init.d/apache2 stop
RUN /etc/init.d/samba stop

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 137 138 139 445 80