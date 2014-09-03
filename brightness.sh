#!/bin/sh
#
# Debian Brightness Control
# @reference:
#   http://cixtor.com/
#   http://cixtor.com/blog/brightness-control
# @usage: This script solves these issues:
#   http://forums.linuxmint.com/viewtopic.php?f=18&t=138760
#   http://forums.linuxmint.com/viewtopic.php?f=59&t=135019
#   http://forums.linuxmint.com/viewtopic.php?f=90&t=129457
#   http://forums.linuxmint.com/viewtopic.php?f=199&t=135699
#
# Brightness is an attribute of visual perception in which a source appears to
# be radiating or reflecting light. In other words, brightness is the perception
# elicited by the luminance of a visual target. This is a subjective attribute
# or property of an object being observed.
#
# Screen brightness can often be tricky to control. On many machines, physical
# hardware switches are missing and software solutions may or may not work well.
# Make sure to find a working method for your hardware! Too bright screens can
# cause eye strain. There are many ways to adjust the screen backlight of a
# monitor, laptop or integrated panel (such as the iMac) using software, but
# depending on hardware and model, sometimes only some options are available.
#

# Select correct dialog manager.
ZENITY=$(which zenity)
MATEDIALOG=$(which matedialog)
if [ $ZENITY ]; then DIALOG="${ZENITY}"; else DIALOG="${MATEDIALOG}"; fi

# Define settings and location of system files.
LEVEL=$($DIALOG --entry --title='Set brightness level' --text='Type a number in range 0-9 representing the\nbrightness level you want for the display')
FILEPATH="/sys/devices/pci0000:00/0000:00:01.0/backlight/acpi_video0/brightness"
FILEPATH="/sys/class/backlight/acpi_video0/brightness"

# Ask for administrative privileges to write in system files.
echo "Setting brightness to: ${LEVEL}"
if [ -w "${FILEPATH}" ]; then
    echo "The brightness file is writable"
else
    echo "Granting permissions to write on the brightness file to the current user"
    gksu chmod 777 "${FILEPATH}"
    if [ -w "${FILEPATH}" ]; then
        echo "Permission to write on the brightness file granted successfully"
    else
        echo "Error granting permission to write on the brightness file"
        $DIALOG --error --title='Set brightness level' --text='Set brightness level\nThe brightness file is not writable.'
    fi
fi

# Set the brightness level defined by the user.
if [ "${LEVEL}" != "" ]; then
    if [ $LEVEL -gt -1 -a $LEVEL -lt 10 ]; then
        echo "${LEVEL}" > "${FILEPATH}"
    else
        echo "Invalid value, use a number in range 0-9"
        $DIALOG --error --title='Set brightness level' --text='Set brightness level\nInvalid value, use a number in range 0-9'
    fi
else
    echo "Invalid value, type a number as argument"
    $DIALOG --error --title='Set brightness level' --text='Set brightness level\nInvalid value, type a number as argument'
fi
