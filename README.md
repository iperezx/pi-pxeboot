# pi-pxeboot
Raspberry Pi PXE boot configuation for both client and server.

## PXE Boot without Docker
Client:
```bash
bash client/setupClient.sh
sudo reboot
```
Server:
```bash
bash server/setupServer.sh
sudo reboot
```

## Install Docker
Install
```bash
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
sudo usermod -aG docker pi
```

Install docker-compose
```bash
sudo apt-get install libffi-dev libssl-dev
sudo apt-get install -y python3 python-pip3
sudo apt-get remove python-configparser
sudo pip3 install docker-compose
```

## Create a docker base image for Raspberry Pi Lite OS
Setting up the docker base container (base on raspberry pi lite os):
```bash
wget -O ospilite.zip https://downloads.raspberrypi.org/raspios_lite_armhf_latest
sudo mkdir $HOME/ospilite/

sudo unzip ospilite.zip -d $HOME/ospilite/
sudo losetup --show -fP $HOME/ospilite/2020-08-20-raspios-buster-armhf-lite.img

sudo mkdir /mnt/rootfs
sudo mkdir /mnt/boot

sudo mount /dev/loop0p1 /mnt/boot
sudo mount /dev/loop0p2 /mnt/rootfs

sudo tar -C /mnt/rootfs -czpf ospilite.tar.gz --numeric-owner .
sudo tar -C /mnt/boot -czpf boot.tar.gz --numeric-owner .

sudo docker build -t ospilite .
sudo docker run -it ospilite:latest bash
```
Note that loop0p1 is the boot config files and loop0p2 is the root filesystem.