#!/system/bin/sh

BB=/sbin/busybox;

mount -o remount,rw /
mount -o remount,rw /system /system


#
# Setup for Cron Task
#
if [ ! -d /data/.SkyHigh ]; then
	$BB mkdir -p /data/.SkyHigh
	$BB chmod -R 0777 /.SkyHigh/
fi;
# Copy Cron files
$BB cp -a /res/crontab/ /data/
if [ ! -e /data/crontab/custom_jobs ]; then
	$BB touch /data/crontab/custom_jobs;
	$BB chmod 777 /data/crontab/custom_jobs;
fi;


#
# Stop Google Service and restart it on boot (dorimanx)
# This removes high CPU load and ram leak!
#
if [ "$($BB pidof com.google.android.gms | wc -l)" -eq "1" ]; then
	$BB kill $($BB pidof com.google.android.gms);
fi;
if [ "$($BB pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
	$BB kill $($BB pidof com.google.android.gms.unstable);
fi;
if [ "$($BB pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
	$BB kill $($BB pidof com.google.android.gms.persistent);
fi;
if [ "$($BB pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
	$BB kill $($BB pidof com.google.android.gms.wearable);
fi;


#
# Set correct r/w permissions for LMK parameters
#
$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree;


#
# We need faster I/O so do not try to force moving to other CPU cores (dorimanx)
#
for i in /sys/block/*/queue; do
        echo "2" > "$i"/rq_affinity
done


#
# Set UKSM CPU governor to low
#
echo "low" > /sys/kernel/mm/uksm/cpu_governor


#
# Set HMP up/down thresholds & prevent TW override
#
echo "479" > /sys/kernel/hmp/up_threshold
$BB chmod 0440 /sys/kernel/hmp/up_threshold
echo "214" > /sys/kernel/hmp/down_threshold
$BB chmod 0440 /sys/kernel/hmp/down_threshold


#
# Fast e/Random Generator (frandom) support on boot
#
chmod 444 /dev/erandom
chmod 444 /dev/frandom


#
# Allow untrusted apps to read from debugfs (mitigate SELinux denials)
#
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app sysfs_devices_system_iosched file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow untrusted_app sysfs_display file { open read write getattr add_name setattr remove_name }" \
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"


#
# Fix for earphone / handsfree no in-call audio
#
if [ -d "/sys/class/misc/arizona_control" ]; then
echo "1" >/sys/class/misc/arizona_control/switch_eq_hp
fi;


#
# Synapse
#
if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

$BB chmod -R 755 /res/*
ln -s /res/synapse/uci /sbin/uci
/sbin/uci


#
# NTFS r/o from /mnt/ntfs
#
mkdir -p /mnt/ntfs
chmod 777 /mnt/ntfs
mount -o mode=0777,gid=1000 -t tmpfs tmpfs /mnt/ntfs


#
# Kernel custom test
#
if [ -e /data/.SkyHigh_test.log ]; then
rm /data/.SkyHigh_test.log
fi

echo  Kernel script is working !!! >> /data/.SkyHigh_test.log
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/.SkyHigh_test.log


if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;


#
# Init.d
#
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/;
	chown -R root.root /system/etc/init.d;
	chmod 777 /system/etc/init.d/;
	chmod 777 /system/etc/init.d/*;
fi;

$BB run-parts /system/etc/init.d


if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;
mkdir /system/su.d
chmod 0700 /system/su.d


$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system /system
$BB mount -o remount,rw /data


#
# Arizona earphone sound default (parametric equalizer preset values by AndreiLux)
#
if [ -d "/sys/class/misc/arizona_control" ]; then
sleep 20;

echo "0x0FF3 0x041E 0x0034 0x1FC8 0xF035 0x040D 0x00D2 0x1F6B 0xF084 0x0409 0x020B 0x1EB8 0xF104 0x0409 0x0406 0x0E08 0x0782 0x2ED8" > /sys/class/misc/arizona_control/eq_A_freqs
echo "0x0C47 0x03F5 0x0EE4 0x1D04 0xF1F7 0x040B 0x07C8 0x187D 0xF3B9 0x040A 0x0EBE 0x0C9E 0xF6C3 0x040A 0x1AC7 0xFBB6 0x0400 0x2ED8" > /sys/class/misc/arizona_control/eq_B_freqs
fi;
