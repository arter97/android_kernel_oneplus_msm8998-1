if [ -f /wlan_aging.ko ]; then
#    beacause system partition must not mount as r/w, so do nothing here
#    ln -s -f /wlan_aging.ko /system/lib/modules/wlan.ko
     echo "init.oem.early_boot.sh go" > /dev/ksmg
fi
