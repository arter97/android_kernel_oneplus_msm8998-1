#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /
mount -t f2fs \
      -o ro,nosuid,nodev,noatime,discard,background_gc=off \
      /dev/block/bootdevice/by-name/userdata /data && \
        ( umount /data; \
          sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             f2fs   nosuid,nodev,noatime,discard,background_gc=off   wait,check,formattable,quota@g' fstab.qcom; \
          touch fstab.ready; \
          echo "Mounted userdata as f2fs"; \
          exit 0 )

# EXT4
if grep -q fileencryption=ice /vendor/etc/fstab.qcom; then
  sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             ext4   nosuid,nodev,noatime,noauto_da_alloc             wait,check,fileencryption=ice,quota@g' /fstab.qcom
else
  sed -i -e 's@USERDATA@/dev/block/bootdevice/by-name/userdata    /data             ext4   nosuid,nodev,noatime,noauto_da_alloc             wait,check,quota@g' /fstab.qcom
fi
touch fstab.ready
