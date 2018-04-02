#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

\ls /sys/fs/f2fs/*/extension_list | while read list; do
  HASH=$(md5sum $list | awk '{print $1}')

  if [[ $HASH == "17167603f89971ed8f9c6acc1e1cc95c" ]]; then
    echo "f2fs-setup.sh: extensions list up-to-date with $list"
    continue
  fi

  echo "f2fs-setup.sh: updating extensions list for $list"

  echo "f2fs-setup.sh: removing previous extensions list"

  HOT=$(cat $list | grep -n 'hot file extensions' | cut -d : -f 1)
  head -n$(($HOT - 1)) $list | grep -v ':' | while read cold; do
    echo "[c]!$cold" > $list
  done

  COLD=$(($(cat $list | wc -l) - $HOT))
  tail -n$COLD | while read hot; do
    echo "[h]!$hot" > $list
  done

  echo "f2fs-setup.sh: writing new extensions list"

  cat /f2fs-cold.list | grep -v '#' | while read cold; do
    if [ ! -z $cold ]; then
      echo "[c]$cold" > $list
    fi
  done

  cat /f2fs-hot.list | while read hot; do
    if [ ! -z $hot ]; then
      echo "[h]$hot" > $list
    fi
  done

done
