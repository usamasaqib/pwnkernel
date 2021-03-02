#!bin/bash

if [[ -e ./rtl ]]
then
	rm -rf ./rtl
fi
mkdir rtl

find -name *.expand -type d -exec cp {} ./rtl

cf=$(ls -la ./rtl | wc -l)

echo "Copied ${cf} rtl files"

