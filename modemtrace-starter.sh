#!/system/bin/sh

FIRSTLOG=`getprop debug.asus.qxdmlog.first`
RUNMTBF=`getprop debug.asus.qxdmlog.mtbf`
    if [ "$FIRSTLOG" == "" ]; then
        setprop debug.asus.qxdmlog.first "1"
        sleep 7
	else
        sleep 1
    fi


    if [ "$RUNMTBF" == "1" ]; then
        DATE="mtbf"
	else
        DATE=`date +%Y_%m_%d_%H_%M_%S`
    fi

OUTDIR=""
WRITE_LOG="log -p d -t ASUS_MTS-SH"
set -x

$WRITE_LOG "run modemtrace-starter" 

STORAGE_TYPE=`getprop persist.asus.qxdmlog.sd1mmc0`
# 0: Internal_storage
# 1: SD_card

    if [ "$STORAGE_TYPE" == "1" ]; then
        OUTDIR="/Removable/MicroSD/diag_logs/QXDM_logs/$DATE"
    else
        OUTDIR="/sdcard/diag_logs/QXDM_logs/$DATE"
    fi

mkdir -p $OUTDIR
if [ ! -w "$OUTDIR" ]; then
    $WRITE_LOG "modemdump-starter.sh: $OUTDIR not writable"
    exit 1
fi

$WRITE_LOG "Writing modemdump data to $OUTDIR ..."
echo "$OUTDIR" >> /data/local/tmp/latestModemDumplogpath.txt

MODEMLEVEL_VALUE=`getprop persist.logtool.modem.level`
if [ "$MODEMLEVEL_VALUE" == "" ]; then
    setprop persist.logtool.modem.level "3"
$WRITE_LOG "Writing level data to $MODEMLEVEL_VALUE ..."
fi

if [ "$RUNMTBF" == "1" ]; then
    setprop persist.logtool.modem.level "5"
fi

#DiagFilter=`getprop persist.asus.qxdmlog.filter`
#if [ "$DiagFilter" == "/system/etc/qxdm/audio.cfg" ]; then
#    setprop persist.logtool.audio.logging "1"
#else
#    setprop persist.logtool.audio.logging "0"
#fi

ROTATE_NUM_VALUE=`getprop persist.asus.qxdmlog.maxfiles`
if [ "$ROTATE_NUM_VALUE" == "" ]; then
    ROTATE_NUM="5"
else
    ROTATE_NUM="$ROTATE_NUM_VALUE"
fi

ROTATE_SIZE_VALUE=`getprop persist.logtool.modem.logsize`

if [ "$ROTATE_SIZE_VALUE" == "" ]; then
        ROTATE_SIZE="100000"
else
        ROTATE_SIZE="$ROTATE_SIZE_VALUE"
fi

#	$WRITE_LOG "Modem: new mts logging ..."

#    setprop persist.asus.qxdmlog.message "1"

    setprop persist.service.mts.input "/dev/mdmTrace"
    setprop persist.service.mts.output "$OUTDIR/Mdumplist.txt"
    setprop persist.service.mts.output_type "f"
    setprop persist.logtool.modem.num "$ROTATE_NUM"
    setprop persist.service.mts.rotate_size "$ROTATE_SIZE"
	/system/bin/asus_mts
	sleep 3
	$WRITE_LOG "Modem: mts service shutdown by unknow reason ..."


