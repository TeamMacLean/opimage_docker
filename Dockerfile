FROM resin/rpi-raspbian:latest
#FROM ubuntu:17.10
#FROM ubuntu:latest
MAINTAINER Martin Page

RUN apt-get update
RUN apt-get install -y git

ADD script2.sh script.sh
RUN chmod +x ./script.sh
RUN ./script.sh


#TODO cleanup: docker rmi $(docker images -q -f dangling=true)