#!/bin/sh

ulog_tag="ArduCopter Bebop"
source /usr/share/ulog/ulog_api.sh

/usr/bin/arducopter.sh prepare
if [ $? -eq 0 ] ; then
	ulogi "Stopping stock autopilot"
	kk
else
	ulogi "Keep Dragon alive"
	exit 0
fi

sleep 1

ulogi "Starting ArduCopter"
prestart arducopter

# notify with 3 blinks, milos and bebop don't handle the led the same way
half_period=50000
(if [ "$(gprop ro.hardware)" = "milosboard" ]; then
	f=/sys/devices/platform/leds_pwm/leds/milos:super_led/brightness
	brightness=150
	old_brightness=$(cat $f)
	for i in 0 1 2; do
		echo ${brightness} > $f
		usleep ${half_period}
		echo 0 > $f
		usleep ${half_period}
	done
	# we reuse the "flying" state, for ledd to set the corresponding
	# pattern, this way, the user know ArduCopter is running.
	# TODO create an ArduCopter dedicated pattern in ledd
	# the property is set to landed before because setting it twice to the
	# same value makes ledd loose it's ground and the led just stops
	sprop autopilot.flying.state landed
	sprop autopilot.flying.state flying
elif [ "$(gprop ro.hardware)" = "mykonos3board" ]; then
	# blink red
	for i in 0 1 2; do
		BLDC_Test_Bench -G 1 0 0
		usleep ${half_period}
		BLDC_Test_Bench -G 0 0 0
		usleep ${half_period}
	done

	# put back to green. we make the assumption the previous state was
	# green, because we have no way to query it
	sleep 2
	BLDC_Test_Bench -G 0 1 0
fi) &
