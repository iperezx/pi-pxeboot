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
Note that ${LOOPDIR}p1 is the boot config files and ${LOOPDIR}p2 is the root filesystem.
This was tested on both a Raspberry PI 4b 4GB and NVIDIA NX Board.

## Docker containers for pxe boot setup
Docker-compose (for nfs and tftp server):
```bash
docker-compose up
```

Option1 - Mount the nfs share directory to the host:
```bash
mount NFS-SERVER-IP:/ /mnt/
```

Run container with the nfs share directory:
```bash
docker run -v /mnt/:/mnt/ iperezx/pi:latest bash
```

On the raspberry pi docker container:
```bash
export bootDir=/mnt/nfs/client1/

export nfsIP="172.18.0.2"
export tftpIP="172.18.0.3"

echo "console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=${nfsIP}:/nfs/client1,vers=4.1,proto=tcp,port=2049 rw ip=dhcp rootwait elevator=deadline" > /mnt/tftp/cmdline.txt

touch ${bootDir}/ssh

sudo rsync -xa --progress --exclude /mnt/ \
    --exclude /etc/systemd/network/10-eth0.netdev \
    --exclude /etc/systemd/network/11-eth0.network \
    --exclude /etc/dnsmasq.conf \
    / ${bootDir}

sudo cp -r /boot/* /mnt/tftp/

echo "proc       /proc        proc     defaults    0    0"   > ${bootDir}/etc/fstab
echo "${nfsIP}:tftp/ /boot nfs4 defaults,nofail,noatime 0 2" >> ${bootDir}/etc/fstab
```