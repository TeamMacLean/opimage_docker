FROM resin/rpi-raspbian:stretch

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
  # Make directory to share
RUN  mkdir /data
  # Adjust Samba configuration
RUN  cat smb.txt >> /etc/samba/smb.conf
  # Stop Samba
RUN  service smbd stop
  # Clean up
RUN  rm smb.txt

EXPOSE 137 138 139 445 80
RUN samba restart
# tese are now installed by APT, but need to chek why it wanted a specific version of cython
#RUN pip install wheel
#RUN pip install cython==0.23
#RUN pip install scikit-image

RUN git clone git://github.com/TeamMacLean/opimage_things
RUN cd opimage_things; sudo python setup.py develop

RUN git clone git://github.com/TeamMacLean/opimage.git
RUN	cd opimage; sudo python setup.py develop

RUN rm -rf /var/www
RUN git clone git://github.com/wookoouk/opimage_interface.git /var/www
RUN chown www-data:www-data /var/www -R
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod cgi

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]