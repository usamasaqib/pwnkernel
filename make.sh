#!/bin/bash -e

cd build

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
