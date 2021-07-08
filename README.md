# McFlight

Description
===========

/bin/onoffbutton
----------------
Is a directory containing four shell scripts that are run by pressing the Bebop power button. See section 4 to learn how to edit and expand this set of scripts.

* shortpress_1.sh
    shuts down the Bebop. **Do not edit this script.**

* shortpress_3.sh
    It is a proprietary script that enables Aurdiocopter mode.

/data/dragon.conf
-----------------
This file stores all the values for the FreeFlight controller software settings. Since these parameters can be set through the FreeFlight software, editing this file makes little sense, but it can be useful to make a backup copy of your settings, just in case. It may anyway be interesting to edit the following:
* "absolute_control"
    sounds like a very intriguing hint at a piloting mode where the controller stick commands are not relative to the drone orientation but ‘absolute’, or rather relative to the pilot position: moving the left stick forward pushes the drone away from you and pulling the stick moves the drone closer. Unfortunately this feature ­which is available for other drones ­ does not seem to be implemented in the current version of the control software, so we do not recommend changing this line. Hopefully future releases could include this option.

* "picture_format" : 0
    changes the photo recording options so that when you take a picture you will get both a JPG and a raw DNG of the fisheye. Such a choice cannot be operated from the FreeFlight settings window, and as soon as you change the recording options through the software, dragon.conf will be modified accordingly.

* "preferred_home_type" : 0
    suggests the “return to home” destination can be set (e.g. to the take­off location, rather than current controller position). This has not been tested yet.

/data/system.conf
-----------------
This file contains a few system parameters. We recommend to leave the file untouched.

/etc/init.d/rcS
---------------
This file is run during the Beebop booting process and controls a number of features that can be edited (see par. 4.3.5).

/usr/bin/DragonStarter.sh
-------------------------
This is a script that starts dragon­prog “and stop what need to be stopped when it stops..." (sic!).
The first lines contain succinct instructions on the options that can be activated when launching this script:

`echo " Dragon Starter start dragon prog and stop what need to be stopped when it stops..."
echo " By default, core dump are enabled."
echo " Options :"
echo " ­h show this help"
echo " ­nfs Use nfs dir as base directory"
echo " ­prog <prog> Use <prog> instead of default prog \"$DEFAULT_PROG\""
echo " ­gdb Start dragon with gdbserver"
echo " ­nogdb Do not start dragon with gdbserver"
echo " ­out2null Send std and stderr output to /dev/null"
echo " ­noout2null Do not send std and stderr output to /dev/null"
echo " ­nocoredump Do not enable coredump"
echo " ­coredump Enable coredump"
echo " ­B Enable Blackbox"
echo " ­b Disable Blackbox"
echo " ­N Enable Navdata"
echo " ­n Disable Navdata"
echo "­­­­­­­­­"`

The following line is of particular interest:
`POST_CMD=""`

*dragon­prog* option strings can be placed between the double quotes to permanently change *dragon­prog* execution (see section 4)

Reference
=========
1. https://www.drohnen-forum.de/index.php/Attachment/24430-Bebop-Hacking-pdf/
