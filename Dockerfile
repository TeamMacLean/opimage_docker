FROM resin/rpi-raspbian:stretch

MAINTAINER Martin Page

RUN apt-get update --fix-missing
RUN apt-get install -y build-essential git
RUN apt-get install -y hostapd dbus net-tools iptables dnsmasq
RUN apt-get install -y git python-dev python-pip python-setuptools python-scipy python-matplotlib
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN pip install wheel
RUN pip install cython==0.23
RUN pip install scikit-image

RUN git clone git://github.com/TeamMacLean/opimage_things
RUN cd opimage_things; sudo python setup.py develop

RUN git clone https://github.com/TeamMacLean/install_opimage.git
RUN cd install_opimage; make opimage

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]