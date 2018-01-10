FROM resin/rpi-raspbian:stretch

MAINTAINER Martin Page

RUN apt-get update --fix-missing
RUN apt-get install -y build-essential zlib1g zlib1g-dev
RUN apt-get install -y hostapd dbus net-tools iptables dnsmasq
RUN apt-get install -y git python-dev python-pip python-setuptools python-wheel python-scipy python-matplotlib python-skimage cython python-tk
#TODO move the below installes to where they SHOULD ve
RUN apt-get install -y apache2
RUN apt-get install -y python-picamera
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

#RUN pip install wheel
#RUN pip install cython==0.23
#RUN pip install scikit-image

RUN git clone git://github.com/TeamMacLean/opimage_things
RUN cd opimage_things; sudo python setup.py develop

RUN git clone git://github.com/TeamMacLean/opimage.git
RUN	cd opimage; sudo python setup.py develop

RUN rm -rf /var/www
RUN echo "testings"; git clone git://github.com/wookoouk/opimage_interface.git /var/www
#RUN chmod 775 /var/www/cgi-bin; chmod 775 /var/www/cgi-bin/*
RUN chown www-data:www-data /var/www -R
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod cgi

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]