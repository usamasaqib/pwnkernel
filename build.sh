#!/bin/bash -e

export KERNEL_VERSION=$1
export BUSYBOX_VERSION=1.32.0

if [ -z $KERNEL_VERSION ]
then
	KERNEL_VERSION=5.4
fi

VERSION=$(echo $KERNEL_VERSION | cut -d '.' -f 1)
BASE_PATH=$(pwd)

#
# make build dir
#
if [ -e ./build ]
then
	rm -rf ./build
fi
mkdir -p ./build
cd build

#
# dependencies
#
echo "[+] Checking / installing dependencies..."
apt-get -q update
apt-get -q install -y bison flex libelf-dev cpio build-essential libssl-dev qemu-system-x86 bc

#
# Linker
# lld causes problems because init section is too big.
# gold is unsupported
# so we make sure that ldd is used
LD_PATH=$(which ld)
LDD_PATH=$(which ldd)
rm $LD_PATH
ln -s $LDD_PATH $LD_PATH

#
# linux kernel
#

echo "[+] Downloading kernel..."
wget -q -c https://mirrors.edge.kernel.org/pub/linux/kernel/v$VERSION.x/linux-$KERNEL_VERSION.tar.gz
[ -e linux-$KERNEL_VERSION ] || tar xzf linux-$KERNEL_VERSION.tar.gz

echo "[+] Building kernel..."
make -C linux-$KERNEL_VERSION defconfig
while read p; do
	echo "$p" >> linux-$KERNEL_VERSION/.config
done < $BASE_PATH/base_kernel.config

if [ -e $BASE_PATH/additional.config ]
then
	while read p; do
		echo "$p" >> linux-$KERNEL_VERSION/.config
	done < $BASE_PATH/additional.config
fi

make -C linux-$KERNEL_VERSION -j16 bzImage

#
# Busybox
#

echo "[+] Downloading busybox..."
wget -q -c https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
[ -e busybox-$BUSYBOX_VERSION ] || tar xjf busybox-$BUSYBOX_VERSION.tar.bz2

echo "[+] Building busybox..."
make -C busybox-$BUSYBOX_VERSION defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' busybox-$BUSYBOX_VERSION/.config
make -C busybox-$BUSYBOX_VERSION -j16
make -C busybox-$BUSYBOX_VERSION install

#
# filesystem
#

echo "[+] Building filesystem..."
cd fs
mkdir -p bin sbin etc proc sys usr/bin usr/sbin root home/ctf
cd ..
cp -a busybox-$BUSYBOX_VERSION/_install/* fs

#
# modules
#

echo "[+] Building modules..."
cd $BASE_PATH/src
make
cd $BASE_PATH
cp src/*.ko fs/
