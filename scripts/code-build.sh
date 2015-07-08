#!/bin/bash

if [[ ! -e main.sh ]]
then
    echo "Must be run in phase2/scripts directory"
    exit 1
fi

cd ..

BASE_DIR=$PWD

echo "************************************************************"
echo "Build smaccmpilot"
echo "************************************************************"

cd smaccmpilot-build/smaccmpilot-stm32f4/src/smaccm-flight

make platform-fmu24/can-server-test-gen
cd platform-fmu24/can-server-test
if [[ ! -e image ]]
then
    echo "Failed to build Pixhawk image"
    exit 1
fi
mv image $BASE_DIR/pixhawk-image

make smaccmpilot-odroid
rm -rf $BASE_DIR/camkes/apps/smaccmpilot
cp -r smaccmpilot $BASE_DIR/camkes/apps/smaccmpilot
cd $BASE_DIR/camkes/apps/smaccmpilot
make
cd $BASE_DIR

echo "************************************************************"
echo "Build kernel image via camkes"
echo "************************************************************"

cd camkes
make smaccmpilot_defconfig
make

cd images
if [[ -e capdl-loader-experimental-image-arm-exynos5 ]]
then
    mkimage -a 0x48000000 -e 0x48000000 -C none -A arm -T kernel -O qnx -d capdl-loader-experimental-image-arm-exynos5 odroid-image
fi

if [[ ! -e odroid-image ]]
then
    echo "Failed to build ODROID image"
    exit 1
fi
mv odroid-image $BASE_DIR/odroid-image

echo "************************************************************"
echo "Pixhawk image: $BASE_DIR/pixhawk-image"
echo "ODROID image: $BASE_DIR/odroid-image"
echo "************************************************************"
