#!/system/bin/sh

cd /root
find . -type f -exec mount --bind {} /system/{} \;
