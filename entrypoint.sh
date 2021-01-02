#!/bin/bash
#
# entrypoint.sh
#
# pimt project
#
# docker script
#

# run web server for viewing of diffs
if [ $# -ne 0 ]; then
    nohup ./pimtweb.py >/dev/null 2>&1 &
    echo -e "started pimt web server in the background\n"
fi

# run pimt with args from docker
./pimt.sh "$@"
