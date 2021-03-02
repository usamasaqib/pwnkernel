#!/bin/bash -e

BASE_PATH=$(pwd)
BUILD_DIR=$(pwd)/build

echo "[+] Building kernel..."
make -C $BUILD_DIR/linux-$KERNEL_VERSION defconfig
while read p; do
        echo "$p" >> $BUILD_DIR/linux-$KERNEL_VERSION/.config
done < $BASE_PATH/base_kernel.config

if [ -e $BASE_PATH/additional.config ]
then
        while read p; do
                echo "$p" >> $BUILD_DIR/linux-$KERNEL_VERSION/.config
        done < $BASE_PATH/additional.config
fi

make -C $BUILD_DIR/linux-$KERNEL_VERSION -j16 bzImage
