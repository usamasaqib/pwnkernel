#!/bin/bash

./download.sh

echo "Modifying Makefiles to pass -fdump-rtl-expand flag to gcc"
./modMake.sh
./make.sh
