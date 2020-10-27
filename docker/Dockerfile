FROM iperezx/ospilite:latest
ENV rootfsDir=/mnt/nfs/client1/ \
    bootDir=/mnt/tftp/ \
    nfsIP="10.0.0.18"

RUN mkdir -p $rootfsDir $bootDir && \
    cp -r /boot/* $bootDir && \
    chroot . dpkg-reconfigure openssh-server && \
    chroot . systemctl enable ssh && \
    rsync -xa --progress --exclude /mnt/ / $rootfsDir && \
    touch ${rootfsDir}/ssh && \
    cp -r /boot/* $bootDir && \
    echo "console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=${nfsIP}:/nfs/client1,vers=4.1,proto=tcp,port=2049 rw ip=dhcp rootwait elevator=deadline" > ${bootDir}cmdline.txt && \
    echo "proc       /proc        proc     defaults    0    0"   > ${rootfsDir}etc/fstab && \
    echo "${nfsIP}:/tftp /boot nfs defaults,vers=3 0 0" >> ${rootfsDir}etc/fstab
