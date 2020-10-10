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
sudo apt-get install -y python3 python3-pip
sudo apt-get remove python-configparser
sudo pip3 install docker-compose
```

## Create a docker base image for Raspberry Pi Lite OS
Setting up the docker base container (base on raspberry pi lite os):
```bash
apt-get install -y wget unzip git
wget -O ospilite.zip https://downloads.raspberrypi.org/raspios_lite_armhf_latest
sudo mkdir $HOME/ospilite/

sudo unzip ospilite.zip -d $HOME/ospilite/
sudo LOOPDIR=$(losetup --show -fP $HOME/ospilite/2020-08-20-raspios-buster-armhf-lite.img)

sudo mkdir -p /mnt/rootfs
sudo mkdir -p /mnt/boot

sudo mount ${LOOPDIR}p1 /mnt/boot
sudo mount ${LOOPDIR}p2 /mnt/rootfs

sudo tar -C /mnt/rootfs -czpf ospilite.tar.gz --numeric-owner .
sudo tar -C /mnt/boot -czpf boot.tar.gz --numeric-owner .

sudo docker build -t iperezx/ospilite:latest -f Dockerfile.ospilite .
sudo docker run -it iperezx/ospilite:latest bash
```
Note that `${LOOPDIR}p1` is the boot config files and `${LOOPDIR}p2` is the root filesystem.
This was tested on both a Raspberry PI 4b 4GB and NVIDIA NX Board.

## Docker containers for pxe boot setup
Create custom nfs server:
```bash
cd $HOME
git clone https://github.com/iperezx/nfs-server-alpine.git
cd nfs-server-alpine
sudo docker build -t iperezx/nfs:latest .
```

Create docker containers:
```bash
docker-compose up -d --build
```

Cleanup:
```bash
docker-compose down && docker volume rm docker_nfs-data
```
