#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /link
find . -type f -exec mount --bind {} /system/{} \;
find . -type l -exec mount --bind {} /system/{} \;
mount --bind /modules /system/lib/modules
mount --bind /modules /vendor/lib/modules

touch /.bind

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

# Set min freq for CPUs
echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 300000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

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
