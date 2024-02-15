#!/bin/sh
chown -R $PUID:$PGID /app /backup

# Start supercronic to load 
/usr/local/bin/supercronic -passthrough-logs cronlist &

Xvfb :99 -screen 0 640x480x8 -nolisten tcp &

/gosu $PUID:$PGID /start.sh
