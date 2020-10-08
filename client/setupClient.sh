#!/bin/bash
#base directory
baseDir=/home/pi/pi-pxeboot/client/
sudo apt-get -y update
sudo apt-get -y full-upgrade
sudo apt-get -y install rpi-eeprom
cd /lib/firmware/raspberrypi/bootloader/beta/
#search for the newest bin pieeprom
export pieepromFile=$(ls -Art | tail -n 1)
sudo cp $pieepromFile new-pieeprom.bin
sudo cp ${baseDir}bootconf-pxeboot.txt bootconf.txt
sudo rpi-eeprom-config --out netboot-pieeprom.bin --config bootconf.txt new-pieeprom.bin
sudo rpi-eeprom-update -d -f ./netboot-pieeprom.bin
sudo systemctl mask rpi-eeprom-update