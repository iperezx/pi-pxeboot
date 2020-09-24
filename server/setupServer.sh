#!/bin/bash

#base directory
baseDir=/home/pi/pi-pxeboot/server/

#Installs and Upgrades
sudo apt-get -y update
sudo apt-get -y full-upgrade
sudo apt-get -y install rpi-eeprom
sudo apt-get -y install rsync dnsmasq nfs-kernel-server

sudo mkdir -p /nfs/client1
sudo mkdir -p /tftpboot
sudo chmod 777 /tftpboot

sudo rsync -xa --progress --exclude /nfs/client1 \
    --exclude /etc/systemd/network/10-eth0.netdev \
    --exclude /etc/systemd/network/11-eth0.network \
    --exclude /etc/dnsmasq.conf \
    / /nfs/client1

cd /nfs/client1
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot . rm /etc/ssh/ssh_host_*
sudo chroot . dpkg-reconfigure openssh-server
sudo chroot . systemctl enable ssh
sudo umount dev sys proc

sudo cp ${baseDir}/10-eth0.netdev /etc/systemd/network/10-eth0.netdev
sudo cp ${baseDir}/11-eth0.network /etc/systemd/network/11-eth0.network

sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd
sudo cp ${baseDir}/dnsmasq.conf /etc/dnsmasq.conf

sudo cp -r /boot/* /tftpboot/
sudo systemctl enable systemd-networkd
sudo systemctl enable dnsmasq.service
sudo systemctl restart dnsmasq.service

sudo cp ${baseDir}/cmdline.txt /tftpboot/cmdline.txt
sudo cp ${baseDir}/exports /etc/exports
sudo cp ${baseDir}/fstab /nfs/client1/etc/fstab

sudo systemctl enable rpcbind
sudo systemctl restart rpcbind
sudo systemctl enable nfs-kernel-server
sudo systemctl restart nfs-kernel-server
