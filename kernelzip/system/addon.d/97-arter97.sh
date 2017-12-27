#!/sbin/sh

. /tmp/backuptool.functions

list_files() {
cat <<EOF
etc/wifi/WCNSS_qcom_cfg.ini
EOF
}

case "$1" in
  backup)
    mv /dev/block/bootdevice/by-name/boot /dev/block/bootdevice/by-name/boot.bak
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
esac
