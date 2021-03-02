#!/bin/bash -e

export KERNEL_VERSION=$1
export BUSYBOX_VERSION=1.32.0

if [ -z $KERNEL_VERSION ]
then
	KERNEL_VERSION=5.4
fi

VERSION=$(echo $KERNEL_VERSION | cut -d '.' -f 1)
BASE_PATH=$(pwd)
BUILD_PATH=$(pwd)/build

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
# linux kernel
#

echo "[+] Downloading kernel..."
wget -q -c https://mirrors.edge.kernel.org/pub/linux/kernel/v$VERSION.x/linux-$KERNEL_VERSION.tar.gz
[ -e linux-$KERNEL_VERSION ] || tar xzf linux-$KERNEL_VERSION.tar.gz
