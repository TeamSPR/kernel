#!/sbin/busybox sh

# Created By Dorimanx and Dairinin
# Modified by UpInTheAir for SkyHigh kernel & Synapse

BB=/sbin/busybox;

ROOTFS_MOUNT=$(mount | grep rootfs | cut -c26-27 | grep -c rw)
if [ "$ROOTFS_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /;
fi;

if [ ! -e /data/crontab/ ]; then
	$BB mkdir /data/crontab/;
fi;

$BB cp -a /res/crontab_service/cron-root /data/crontab/root;
chown 0:0 /data/crontab/root;
chmod 777 /data/crontab/root;
if [ ! -d /var/spool/cron/crontabs ]; then
	mkdir -p /var/spool/cron/crontabs/;
fi;
$BB cp -a /data/crontab/root /var/spool/cron/crontabs/;

chown 0:0 /var/spool/cron/crontabs/*;
chmod 777 /var/spool/cron/crontabs/*;

# Check device local timezone & set for cron tasks
timezone=`date +%z`
if $BB [ $timezone = "+1400" ]; then
	TZ=UCT-14
elif $BB [ $timezone = "+1300" ]; then
	TZ=UCT-13
elif $BB [ $timezone = "+1245" ]; then
	TZ=CIST-12:45CIDT
elif $BB [ $timezone = "+1200" ]; then
	TZ=NZST-12NZDT
elif $BB [ $timezone = "+1100" ]; then
	TZ=UCT-11
elif $BB [ $timezone = "+1030" ]; then
	TZ= LHT-10:30LHDT
elif $BB [ $timezone = "+1000" ]; then
	TZ=UCT-10
elif $BB [ $timezone = "+0930" ]; then
	TZ=UCT-9:30
elif $BB [ $timezone = "+0900" ]; then
	TZ=UCT-9
elif $BB [ $timezone = "+0830" ]; then
	TZ=KST
elif $BB [ $timezone = "+0800" ]; then
	TZ=UCT-8
elif $BB [ $timezone = "+0700" ]; then
	TZ=UCT-7
elif $BB [ $timezone = "+0630" ]; then
	TZ=UCT-6:30
elif $BB [ $timezone = "+0600" ]; then
	TZ=UCT-6
elif $BB [ $timezone = "+0545" ]; then
	TZ=UCT-5:45
elif $BB [ $timezone = "+0530" ]; then
	TZ=UCT-5:30
elif $BB [ $timezone = "+0500" ]; then
	TZ=UCT-5
elif $BB [ $timezone = "+0430" ]; then
	TZ=UCT-4:30
elif $BB [ $timezone = "+0400" ]; then
	TZ=UCT-4
elif $BB [ $timezone = "+0330" ]; then
	TZ=UCT-3:30
elif $BB [ $timezone = "+0300" ]; then
	TZ=UCT-3
elif $BB [ $timezone = "+0200" ]; then
	TZ=UCT-2
elif $BB [ $timezone = "+0100" ]; then
	TZ=UCT-1
elif $BB [ $timezone = "+0000" ]; then
	TZ=UCT
elif $BB [ $timezone = "-0100" ]; then
	TZ=UCT1
elif $BB [ $timezone = "-0200" ]; then
	TZ=UCT2
elif $BB [ $timezone = "-0300" ]; then
	TZ=UCT3
elif $BB [ $timezone = "-0330" ]; then
	TZ=NST3:30NDT
elif $BB [ $timezone = "-0400" ]; then
	TZ=UCT4
elif $BB [ $timezone = "-0430" ]; then
	TZ=UCT4:30
elif $BB [ $timezone = "-0500" ]; then
	TZ=UCT5
elif $BB [ $timezone = "-0600" ]; then
	TZ=UCT6
elif $BB [ $timezone = "-0700" ]; then
	TZ=UCT7
elif $BB [ $timezone = "-0800" ]; then
	TZ=UCT8
elif $BB [ $timezone = "-0900" ]; then
	TZ=UCT9
elif $BB [ $timezone = "-0930" ]; then
	TZ=UCT9:30
elif $BB [ $timezone = "-1000" ]; then
	TZ=UCT10
elif $BB [ $timezone = "-1100" ]; then
	TZ=UCT11
elif $BB [ $timezone = "-1200" ]; then
	TZ=UCT12
else
	TZ=UCT
fi

export TZ

#Set Permissions to scripts
chown 0:0 /data/crontab/cron-scripts/*;
chmod 777 /data/crontab/cron-scripts/*;

# use /var/spool/cron/crontabs/ call the crontab file "root"
if [ "$(pidof crond | wc -l)" -eq "0" ]; then
	$BB nohup /system/xbin/crond -c /var/spool/cron/crontabs/ > /data/.SkyHigh/cron.txt &
	sleep 1;
	PIDOFCRON=$(pidof crond);
	echo "-900" > /proc/"$PIDOFCRON"/oom_score_adj;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
