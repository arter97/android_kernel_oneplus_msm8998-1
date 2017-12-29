#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /root
find . -type f -exec mount --bind {} /system/{} \;
