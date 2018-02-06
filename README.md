# OPImage Docker

## setup raspberry pi 3
* installed current stable version of rasbian (tested with stretch).
* install docker: `curl -sSL https://get.docker.com | sh`


## run container
`docker run --privileged --net=host --device=/dev/vchiq --restart=always teammaclean/opimage_docker`

* The wifi being broadcast will be called `OPImage` and the password is `raspberry`.
* The IP address of the server will be 10.0.0.1 and your IP will be in this range.
* Samba is running on the server and can be connected to with the username `root` and password `password`


## common errors //TODO
* run `rfkill unblock wifi` (softblock fix) if the wifi adapter is being rejected
* run `sudo chmod 777 /dev/vchiq` if getting `permission denied` when running the script