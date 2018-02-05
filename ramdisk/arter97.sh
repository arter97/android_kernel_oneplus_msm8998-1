#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

ln -s /sys/kernel/boot_wlan/boot_wlan /dev/wlan
chown -h wifi:wifi /sys/kernel/boot_wlan/boot_wlan
chown -h wifi:wifi /dev/wlan
chmod 640 /sys/kernel/boot_wlan/boot_wlan
chmod 640 /dev/wlan

cd /link
find . -type f -exec mount --bind {} /system/{} \;
find . -type l -exec mount --bind {} /system/{} \;
mount --bind /system/lib/modules /system/vendor/lib/modules

touch /.bind

while ! grep -q MacAddress /persist/wlan_mac.bin; do
  sleep 1
done

echo 1 > /sys/kernel/boot_wlan/boot_wlan

while ! pgrep -f com.android.systemui > /dev/null; do
  sleep 1
done
while pgrep -f bootanimation > /dev/null; do
  sleep 1
done

# Configure input boost
echo "1248000 1344000" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 90 > /sys/module/cpu_boost/parameters/input_boost_ms
echo "1171200 1190400" > /sys/module/cpu_boost/parameters/input_boost_freq_s2
echo 150 > /sys/module/cpu_boost/parameters/input_boost_ms_s2

# Configure CPU governor
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/enable_prediction
echo 59000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis

# Disable console suspend
echo N > /sys/module/printk/parameters/console_suspend

# Disable userspace intervention
chmod 444 \
  /sys/module/cpu_boost/parameters/input_boost_freq \
  /sys/module/cpu_boost/parameters/input_boost_ms \
  /sys/module/cpu_boost/parameters/input_boost_freq_s2 \
  /sys/module/cpu_boost/parameters/input_boost_ms_s2 \
  /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction \
  /sys/devices/system/cpu/cpu4/cpufreq/interactive/enable_prediction \
  /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis \
  /sys/module/printk/parameters/console_suspend
