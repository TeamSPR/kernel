#!/bin/bash

###############################################################################
# To all DEV around the world :)                                              #
# to build this kernel you need to be ROOT and to have bash as script loader  #
# do this:                                                                    #
# cd /bin                                                                     #
# rm -f sh                                                                    #
# ln -s bash sh                                                               #
#                                                                             #
# Now you can build my kernel.                                                #
# using bash will make your life easy. so it's best that way.                 #
# Have fun and update me if something nice can be added to my source.	      #
#                                                         		      #
# Original scripts by halaszk					      	      #
# modified by UpInTheAir for SkyHigh kernels				      #
#                                                         		      #
###############################################################################

# Time of build startup
res1=$(date +%s.%N)

echo "${bldcya}***** Setting up Environment *****${txtrst}";

. ./env_setup.sh ${1} || exit 1;

if [ ! -f $KERNELDIR/.config ]; then
	echo "${bldcya}***** Writing Config *****${txtrst}";
	cp $KERNELDIR/arch/arm64/configs/$KERNEL_CONFIG .config;
	make ARCH=arm64 $KERNEL_CONFIG;
fi;

. $KERNELDIR/.config

# remove previous Image files
if [ -e $KERNELDIR/arch/arm64/boot/Image ]; then
	rm $KERNELDIR/arch/arm64/boot/Image;
fi;
if [ -e $KERNELDIR/arch/arm64/boot/dt.img ]; then
	rm $KERNELDIR/arch/arm64/boot/dt.img;
fi;

# Cleanup old dtb files
rm -rf $KERNELDIR/arch/arm64/boot/dts/*.dtb;

echo "Done"

# make Image
echo "${bldcya}***** Compiling kernel *****${txtrst}"
if [ $USER != "root" ]; then
	make CONFIG_DEBUG_SECTION_MISMATCH=y -j5 Image ARCH=arm64
else
	make -j5 Image ARCH=arm64
fi;

if [ -e $KERNELDIR/arch/arm64/boot/Image ]; then
	echo "${bldcya}***** Final Touch for Kernel *****${txtrst}"
	stat $KERNELDIR/arch/arm64/boot/Image || exit 1;
	
	echo "--- Creating dt.img ---"
	./utilities/dtbtool -o dt.img -s 2048 -p ./scripts/dtc/dtc ./arch/arm64/boot/dts/
	mv ./dt.img ./arch/arm64/boot/

echo ""
echo "${bldcya}***** Compiled Image and dt.img found in directory /arch/arm64/boot/ *****${txtrst}";
echo ""

	exit 0;
else
	echo "${bldred}Kernel STUCK in BUILD!${txtrst}"
fi;
