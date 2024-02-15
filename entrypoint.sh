#!/bin/sh
chown -R $PUID:$PGID /app /backup

# make sure Xvfb is dead
rm /tmp/.X*-lock
Xvfb $DISPLAY -screen 0 640x480x8 -nolisten tcp &
XVFB_PROC=$!

/gosu $PUID:$PGID /start.sh

kill $XVFB_PROC