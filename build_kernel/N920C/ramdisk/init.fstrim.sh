#!/sbin/busybox sh

exec 2>&1 > /dev/kmsg

export PATH=/sbin:$PATH

fstrim -v /system
fstrim -v /cache
fstrim -v /data

sync
