#!/bin/bash

export ARCH=arm64

# Clean up
make clean
make mrproper
ccache -c

# Set toolchain
export CROSS_COMPILE=/home/upintheair/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# Make .config
# SM-N920C SEA
make ARCH=arm64 SkyHigh_defconfig
# SM-N920CD MEA
#make ARCH=arm64 SkyHigh_SM-N920CD_MEA_defconfig
# SM-N920I SEA
#make ARCH=arm64 SkyHigh_SM-N920I_defconfig
# SM-N920P Sprint
#make ARCH=arm64 SkyHigh_SM-N920P_Sprint_defconfig
# SM-N920R4 US Cellular (cdma)
#make ARCH=arm64 SkyHigh_SM-N920R4_USC_defconfig
# SM-N920S/K/L Korea
#make ARCH=arm64 SkyHigh_SM-N920S_defconfig
# SM-N9200 Hong Kong
#make ARCH=arm64 SkyHigh_SM-N9200_HK_defconfig
# SM-N9208 SEA
#make ARCH=arm64 SkyHigh_SM-N9208_SEA_defconfig
# SM-N9208 Taiwan
#make ARCH=arm64 SkyHigh_SM-N9208_TW_defconfig
# SM-N920T T-Mobile
#make ARCH=arm64 SkyHigh_tmo_defconfig

# Compile Image
make -j5 ARCH=arm64
