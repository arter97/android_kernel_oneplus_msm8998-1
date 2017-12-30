#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /
mount -t f2fs \
      -o nosuid,nodev,noatime,discard,background_gc=off \
      /dev/block/bootdevice/by-name/userdata /data && \
        ( grep -v userdata fstab.qcom > fstab.tmp; \
          mv fstab.tmp fstab.qcom; \
          touch /fstab.ready; \
          echo "Mounted userdata as f2fs" )
