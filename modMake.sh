#!/bin/sh

find -name Makefile -type f -exec sed -i '1s/^/ccflags-y += -fdump-rtl-expand\n/' {}
