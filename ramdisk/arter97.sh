#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /root
find . -type f -exec mount --bind {} /system/{} \;

while ! pgrep -f com.android.systemui > /dev/null; do
  sleep 1
done
while pgrep -f bootanimation > /dev/null; do
  sleep 1
done

# Configure input boost
echo "0:1248000 4:1344000" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 90 > /sys/module/cpu_boost/parameters/input_boost_ms
echo "0:1171200 4:1190400" > /sys/module/cpu_boost/parameters/input_boost_freq_s2
echo 150 > /sys/module/cpu_boost/parameters/input_boost_ms_s2
chmod 444 /sys/module/cpu_boost/parameters/input_boost_ms
chmod 444 /sys/module/cpu_boost/parameters/input_boost_freq_s2
