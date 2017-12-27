#!/bin/bash

if [ -e vmlinux ]; then
	make mrproper -j$(grep -c ^processor /proc/cpuinfo) -i 2>/dev/null
fi

git reset --hard

git ls-files . --ignored --exclude-standard --others --directory | while read file; do echo $file; rm -rf $file; done
git ls-files . --exclude-standard --others --directory | while read file; do echo $file; rm -rf $file; done

cp defconfig .config
