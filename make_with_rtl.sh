#!/bin/bash

if [[ -e ./rtl ]]
then
	rm -rf ./rtl
fi
mkdir ./rtl

find -name *.expand -type f -exec cp {} ./rtl

cf=$(ls ./rtl | wc -w)
RTL_PATH=$(pwd)/rtl
echo "Copied ${cf} rtl dump files to ${RTL_PATH}"
