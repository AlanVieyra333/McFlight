#!/bin/sh -
source /bin/ardrone3_shell.sh

DEFAULT_PROG="usr/bin/dragon-prog"

PROG_BASE_DIR="/"
USE_GDB=0
NO_CORE_DUMP=0
OUT2NULL=0
BLACKBOX=0
NAVDATA=0
VIDEO_DEBUG=0
FRAME_INFO_DUMP=0
FRAME_INFO_STREAM=0
FRAME_INFO_RECORD=0
NMEA_DUMP=0
PROG=$DEFAULT_PROG


POST_CMD=$(gprop persist.dragon-prog.post_cmd)
if [ -z "${POST_CMD}" ]; then
    POST_CMD=""
else
    echo "dragon-prog with custom options: ${POST_CMD}"
fi
PRE_CMD=""

if [ -f /etc/debug.conf ]
then
  source /etc/debug.conf
fi

usage()
{
    echo "---------"
    echo " $0 : USAGE :"
    echo "---------"
    echo " Dragon Starter start dragon prog and stop what need to be stopped when it stops..."
    echo " By default, core dump are enabled."
    echo " Options :"
    echo "   -h             show this help"
    echo "   -nfs           Use nfs dir as base directory"
    echo "   -prog <prog>   Use <prog> instead of default prog \"$DEFAULT_PROG\""
    echo "   -gdb           Start dragon with gdbserver"
    echo "   -nogdb         Do not start dragon with gdbserver"
    echo "   -out2null      Send std and stderr output to /dev/null"
    echo "   -noout2null    Do not send std and stderr output to /dev/null"
    echo "   -nocoredump    Do not enable coredump"
    echo "   -coredump      Enable coredump"
    echo "   -B             Enable Blackbox"
    echo "   -b             Disable Blackbox"
    echo "   -N             Enable Navdata"
    echo "   -n             Disable Navdata"
    echo "   -k             enable video debug"
    echo "   -K             Disable video debug"
    echo "---------"
}

while [ $# -ne 0 ]; do
    if [ "$1" = "-h" ]; then
        usage
        exit 0
    elif [ "$1" = "-gdb" ]; then
        USE_GDB=1
        shift
    elif [ "$1" = "-nogdb" ]; then
        USE_GDB=0
        shift
    elif [ "$1" = "-nfs" ]; then
        PROG_BASE_DIR="/mnt/nfs"
        shift
    elif [ "$1" = "-prog" ]; then
        shift
        if [ $# -ne 0 ]; then
            PROG=$1
            shift
        else
            echo "<ProgArg> missing after -prog option"
            exit 1
        fi
    elif [ "$1" = "-out2null" ]; then
        shift
        OUT2NULL=1
    elif [ "$1" = "-noout2null" ]; then
        shift
        OUT2NULL=0
    elif [ "$1" = "-nocoredump" ]; then
        shift
        NO_CORE_DUMP=1
    elif [ "$1" = "-coredump" ]; then
        shift
        NO_CORE_DUMP=0
    elif [ "$1" = "-B" ]; then
        shift
        BLACKBOX=1
     elif [ "$1" = "-b" ]; then
        shift
        BLACKBOX=0
    elif [ "$1" = "-N" ]; then
        shift
        NAVDATA=1
     elif [ "$1" = "-n" ]; then
        shift
        NAVDATA=0
    elif [ "$1" = "-k" ]; then
        shift
        VIDEO_DEBUG=1
     elif [ "$1" = "-K" ]; then
        shift
        VIDEO_DEBUG=0
   else
        echo "Unknown option"
        usage
        exit 1
    fi
done

if [ $USE_GDB -eq 1 ]; then
    PRE_CMD="gdbserver 1.1.1.1:10000"
fi

if [ $BLACKBOX -eq 1 ]
then
    [ ! -d ${ARDRONE3_BLACKBOX_PATH} ] && mkdir -p ${ARDRONE3_BLACKBOX_PATH}
    POST_CMD="${POST_CMD} -B"
fi

[ ! -d ${ARDRONE3_FPLAN_BACKUP_PATH} ] && mkdir -p ${ARDRONE3_FPLAN_BACKUP_PATH}

if [ $NAVDATA -eq 1 ]
then
    POST_CMD="${POST_CMD} -N"
fi

if [ $VIDEO_DEBUG -eq 1 ]
then
    POST_CMD="${POST_CMD} -k"
fi

if [ $FRAME_INFO_DUMP -eq 1 ]
then
  POST_CMD="${POST_CMD} -n"
fi

if [ $FRAME_INFO_STREAM -eq 1 ]
then
  POST_CMD="${POST_CMD} -o"
fi

if [ $FRAME_INFO_RECORD -eq 1 ]
then
  POST_CMD="${POST_CMD} -O"
fi

if [ $NMEA_DUMP -eq 1 ]
then
  sprop persist.nmea.record 1
else
  sprop persist.nmea.record 0
fi

PROG_CMD="$PRE_CMD $PROG_BASE_DIR/$PROG $POST_CMD"

if [ $NO_CORE_DUMP -eq 0 ]; then
  [ ! -d ${ARDRONE3_CORES_PATH} ] && mkdir -p ${ARDRONE3_CORES_PATH}
  source /usr/bin/activate_coredump.sh
fi

# Start program... :
echo "Exec : $PROG_CMD" | ulogger -t "Dragon" -p I
if [ $OUT2NULL -eq 1 ]; then
    echo "(output send to /dev/null)" | ulogger -t "Dragon" -p I
    $PROG_CMD >/dev/null 2>/dev/null
    PROG_RESULT=$?
else
    $PROG_CMD
    PROG_RESULT=$?
fi

echo ""
echo "dragon-prog is dead. Security launched: stop heating IMU sensors !" | ulogger -t "Dragon" -p N
nr_pwm=$(cat /sys/kernel/hsis/thermal_pwm)
name_pwm=$(printf "/sys/class/pwm/pwm_%d" ${nr_pwm})
echo 0 > ${name_pwm}/run
echo "Date is: $(date -R)" | ulogger -t "Dragon" -p N

if [ "$PRODUCT" = "Chimera" ]
then
ldc set_pattern error_dragon_dead false
fi

echo ""
echo "############################"
echo "### Dragon returned = $PROG_RESULT"
echo "Dragon returned = $PROG_RESULT"| ulogger -t "Dragon" -p N
echo "############################"
echo ""
exit $PROG_RESULT

