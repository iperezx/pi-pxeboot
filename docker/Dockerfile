FROM iperezx/ospilite:pi
ENV rootfsDir=/mnt/nfs/client1/ \
    bootDir=/mnt/tftp/ \
    nfsIP="172.18.0.2" \
    tftpIP="172.18.0.3"

RUN mkdir -p $rootfsDir $bootDir && \
    cp -r /boot/* $bootDir && \
    rsync -xa --progress --exclude /mnt/ / $rootfsDir && \
    touch ${rootfsDir}/ssh && \
    cp -r /boot/* $bootDir && \
    echo "console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=${nfsIP}:/nfs/client1,vers=4.1,proto=tcp,port=2049 rw ip=dhcp rootwait elevator=deadline" > ${bootDir}cmdline.txt && \
    echo "proc       /proc        proc     defaults    0    0"   > ${rootfsDir}etc/fstab && \
    echo "${nfsIP}:tftp/ /boot nfs4 defaults,nofail,noatime 0 2" >> ${rootfsDir}etc/fstab
