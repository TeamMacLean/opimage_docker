FROM resin/rpi-raspbian:stretch

MAINTAINER Martin Page

RUN apt-get update --fix-missing
RUN apt-get install -y build-essential zlib1g zlib1g-dev
RUN apt-get install -y hostapd dbus net-tools iptables dnsmasq
RUN apt-get install -y git python-dev python-pip python-setuptools python-wheel python-scipy python-matplotlib python-skimage cython
RUN apt-get install -y apache2
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

#RUN pip install wheel
#RUN pip install cython==0.23
#RUN pip install scikit-image

RUN git clone git://github.com/TeamMacLean/opimage_things
RUN cd opimage_things; sudo python setup.py develop

RUN git clone git://github.com/TeamMacLean/opimage.git
RUN	cd opimage; sudo python setup.py develop

RUN rm -rf /var/www/html
RUN git clone git://github.com/TeamMacLean/opimage_interface.git /var/www/html
RUN chmod 775 /var/www/html/cgi-bin/*

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]