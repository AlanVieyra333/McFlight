#!/bin/sh

ardupilot=/usr/bin/arducopter
rw_ardupilot=/data/ftp/internal_000/ardupilot/arducopter

if [ -f "${rw_ardupilot}" ]; then
	chmod +x ${rw_ardupilot}
	ardupilot=${rw_ardupilot}
fi

if [ -x "${ardupilot}" ]; then
	ret=0
else
	ret=1
fi

if [ "$1" = "prepare" ]; then
	exit $ret
else
	exec ${ardupilot} $@
fi

