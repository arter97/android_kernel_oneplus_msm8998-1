#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /
mount -t f2fs \
      -o ro,nosuid,nodev,noatime,discard,background_gc=off \
      /dev/block/bootdevice/by-name/userdata /data && \
        ( umount /data; \
          sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             f2fs   nosuid,nodev,noatime,discard,background_gc=off   wait,formattable,quota@g' fstab.qcom; \
          touch fstab.ready; \
          echo "Mounted userdata as f2fs"; )

if [ -e fstab.ready ]; then
  exit 0
fi

# EXT4
if grep /dev/block/bootdevice/by-name/userdata /system/vendor/etc/fstab.qcom | grep -q fileencryption=ice; then
  sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             ext4   nosuid,nodev,noatime,noauto_da_alloc             wait,check,fileencryption=ice,quota@g' /fstab.qcom
else
  sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             ext4   nosuid,nodev,noatime,noauto_da_alloc             wait,check,quota@g' /fstab.qcom
fi
rm /link/lib/libsqlite.so /link/lib64/libsqlite.so
touch fstab.ready
