#!/bin/bash

export ARCH=arm64

# Clean up
make clean
make mrproper
ccache -c

# Set toolchain
export CROSS_COMPILE=/home/upintheair/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# Make .config
make ARCH=arm64 SkyHigh_defconfig
# T-Mobile
#make ARCH=arm64 SkyHigh_tmo_defconfig

# Compile Image
make -j5 ARCH=arm64
