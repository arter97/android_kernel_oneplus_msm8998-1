#!/bin/bash
export KERNELDIR=`readlink -f .`
export RAMFS_SOURCE=`readlink -f $KERNELDIR/ramdisk`
export PARTITION_SIZE=67108864

echo "kerneldir = $KERNELDIR"
echo "ramfs_source = $RAMFS_SOURCE"

RAMFS_TMP="/tmp/arter97-op5-ramdisk"

echo "ramfs_tmp = $RAMFS_TMP"
cd $KERNELDIR

if [ "${1}" = "skip" ] ; then
	echo "Skipping Compilation"
else
	echo "Compiling kernel"
	cp defconfig .config
	make "$@" || exit 1
fi

echo "Building new ramdisk"
#remove previous ramfs files
rm -rf '$RAMFS_TMP'*
rm -rf $RAMFS_TMP
rm -rf $RAMFS_TMP.cpio
#copy ramfs files to tmp directory
cp -axpP $RAMFS_SOURCE $RAMFS_TMP
find $(\ls -d * | grep -wv ramdisk) -name '*.ko' -exec cp -n {} $RAMFS_TMP/modules \;
$(cat Makefile | grep CROSS_COMPILE | tr ' ' '\n' | grep '/' | tail -n1)strip --strip-debug --strip-unneeded $RAMFS_TMP/modules/*.ko 2>/dev/null
cd $RAMFS_TMP

#clear git repositories in ramfs
find . -name .git -exec rm -rf {} \;
find . -name EMPTY_DIRECTORY -exec rm -rf {} \;

if [ "${1}" = "skip" ] ; then
	# Use Magisk
	mv init .backup/init.tmp
	mv .backup/init .
	mv .backup/init.tmp .backup/init
fi

$KERNELDIR/ramdisk_fix_permissions.sh 2>/dev/null

cd $KERNELDIR
rm -rf $RAMFS_TMP/tmp/*

cd $RAMFS_TMP
find . | fakeroot cpio -H newc -o | lz4 -l -9 > $RAMFS_TMP.cpio.lz4
ls -lh $RAMFS_TMP.cpio.lz4
cd $KERNELDIR

echo "Making new boot image"
gcc -w -s -pipe -O2 -Itools/libmincrypt -o tools/mkbootimg/mkbootimg tools/libmincrypt/*.c tools/mkbootimg/mkbootimg.c
tools/mkbootimg/mkbootimg --kernel $KERNELDIR/arch/arm64/boot/Image.gz-dtb --ramdisk $RAMFS_TMP.cpio.lz4 --cmdline 'androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 sched_enable_hmp=1 sched_enable_power_aware=1 service_locator.enable=1 swiotlb=2048 buildvariant=user' --base 0x00008000 --pagesize 4096 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --second_offset 0x00f00000 -o $KERNELDIR/boot.img
GENERATED_SIZE=$(stat -c %s boot.img)
if [[ $GENERATED_SIZE -gt $PARTITION_SIZE ]]; then
	echo "boot.img size larger than partition size!" 1>&2
	exit 1
fi

echo "done"
ls -al boot.img
echo ""
