#!/bin/bash

echo "Use Ctrl+] to send interrupt to QEMU. Sleeping for 3 seconds..."
stty intr ^]

#
# build root fs
#
pushd fs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
popd

FS_MOUNT=$MOUNT_PATH
if [ -z FS_MOUNT ]
then
	FS_MOUNT=$HOME
fi

#
# launch
#
/usr/bin/qemu-system-x86_64 \
	-kernel linux-5.4/arch/x86/boot/bzImage \
	-m 5G \
	-smp 4 \
	-initrd $PWD/initramfs.cpio.gz \
	-fsdev local,security_model=passthrough,id=fsdev0,path=$FS_MOUNT \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	-nographic \
	-monitor none \
	-s \
	-append "console=ttyS0 nokaslr"
