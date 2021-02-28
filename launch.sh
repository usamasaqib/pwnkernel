#!/bin/bash

BUILD_DIR=$(pwd)/build

echo "Use Ctrl+] to send interrupt to QEMU. Sleeping for 3 seconds..."
stty intr ^]

#
# build root fs
#
pushd fs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
popd

#
# launch
#
/usr/bin/qemu-system-x86_64 \
	-kernel $BUILD_DIR/linux-5.4/arch/x86/boot/bzImage \
	-m 5G \
	-smp $(nproc) \
	-initrd $PWD/initramfs.cpio.gz \
	-fsdev local,security_model=passthrough,id=fsdev0,path=$HOME \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	-nographic \
	-monitor none \
	-s \
	-append "console=ttyS0 nokaslr"
