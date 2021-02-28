#!/bin/bash

set -e
set -x

TITLE=MAVLinkRouter
MAVLINKROUTER_HOME=$HOME/startupscripts
SCRIPT=$MAVLINKROUTER_HOME/start_mav.sh
LOG=$MAVLINKROUTER_HOME/autostart_mav.log

# autostart for mavproxy
(
    set -e
    set -x

    date
    set

    cd $MAVLINKROUTER_HOME
    screen -L -d -m -S "$TITLE" -s /bin/bash $SCRIPT
) >$LOG 2>&1
exit 0
