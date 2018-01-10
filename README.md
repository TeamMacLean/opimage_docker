# OPImage Docker

`docker run --privileged --net=host --device=/dev/vchiq --restart=always teammaclean/opimage_docker`

wifi password: raspberry  
server address: 10.0.0.1  
samba username: root  
samba password: password  

`sudo chmod 777 /dev/vchiq`

softblock fix: `rfkill unblock wifi`