#!/sbin/busybox sh

cat << CTAG
{
    name:IO,
    elements:[
    	{ SPane:{
		title:"I/O Schedulers",
		description:" Set the active I/O elevator algorithm. The I/O Scheduler decides how to prioritize and handle I/O requests. More info: <a href='http://timos.me/tm/wiki/ioscheduler'>Wiki</a>"
    	}},
	{ SSpacer:{
		height:1
	}},
	{ SOptionList:{
		title:"Storage scheduler",
		default:`cat /sys/block/sda/queue/scheduler | busybox awk 'NR>1{print $1}' RS=[ FS=]`,
		action:"scheduler /sys/block/sda/queue/scheduler",
		values:[`while read values; do busybox printf "%s, \n" $values | busybox tr -d '[]'; done < /sys/block/sda/queue/scheduler`],
		notify:[
			{
				on:APPLY,
				do:[ REFRESH, CANCEL ],
				to:"/sys/block/sda/queue/iosched"
			},
			{
				on:REFRESH,
				do:REFRESH,
				to:"/sys/block/sda/queue/iosched"
			}
		]
	}},
	{ SSpacer:{
		height:1
	}},
	{ SSeekBar:{
		title:"Storage Read-Ahead",
		description:" ",
		max:4096,
		min:64,
		unit:" KB",
		step:64,
		default:`cat /sys/block/sda/queue/read_ahead_kb`,
		action:"generic /sys/block/sda/queue/read_ahead_kb"
	}},
	{ SSpacer:{
		height:1
	}},
	{ SPane:{
		title:"General I/O Tunables",
		description:" Set the internal storage general tunables"
	}},
	{ SSpacer:{
		height:1
	}},
	{ SCheckBox:{
		description:" Draw entropy from spinning (rotational) storage. Default is Disabled.\n",
		label:"Add Random",
		default:`cat /sys/block/sda/queue/add_random`,
		action:"generic /sys/block/sda/queue/add_random"
	}},
	{ SSpacer:{
		height:1
	}},
	{ SCheckBox:{
		description:" Maintain I/O statistics for this storage device. Disabling will break I/O monitoring apps but reduce CPU overhead.\n Default is Disabled.\n",
		label:"I/O Stats",
		default:`cat /sys/block/sda/queue/iostats`,
		action:"generic /sys/block/sda/queue/iostats"
	}},
	{ SSpacer:{
		height:1
	}},
	{ SCheckBox:{
		description:" Treat device as rotational storage. Default is Disabled.\n",
		label:"Rotational",
		default:`cat /sys/block/sda/queue/rotational`,
		action:"generic /sys/block/sda/queue/rotational"
	}},
	{ SSpacer:{
		height:1
	}},
	{ SOptionList:{
		title:"No Merges",
		description:" Types of merges (prioritization) the scheduler queue for this storage device allows. Default is All.",
		default:`cat /sys/block/sda/queue/nomerges`,
		action:"generic /sys/block/sda/queue/nomerges",
		values:{
			`NM='0:"All", 1:"Simple Only", 2:"None",'
			echo $NM`
		}
	}},
	{ SSpacer:{
		height:1
	}},
	{ SOptionList:{
		title:"RQ Affinity",
		description:" Try to have scheduler requests complete on the CPU core they were made from. Default is Aggressive.",
		default:`cat /sys/block/sda/queue/rq_affinity`,
		action:"generic /sys/block/sda/queue/rq_affinity",
		values:{
			`RQA='0:"Disabled", 1:"Enabled", 2:"Aggressive"'
			echo $RQA`
		}
	}},
	{ SSpacer:{
		height:1
	}},
	{ SPane:{
		title:"I/O Scheduler Tunables"
	}},
	{ SSpacer:{
		height:1
	}},
	{ STreeDescriptor:{
		path:"/sys/block/sda/queue/iosched",
		generic: {
			directory: {},
			element: {
				SGeneric: { title:"@BASENAME" }
			}
		},
		exclude: [ "weights", "wr_max_time" ]
	}},
    ]
}
CTAG
