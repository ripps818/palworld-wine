#!/bin/bash
DATE=`date +%Y%m%d%H`
PALDIR="/app/steamapps/common/PalServer/Pal"

# Backup Binaries and Saved directories.
if [ "${BACKUP_ENABLED,,}" = true ]; then
	# We save Binaries because most mods their configs live there.
	tar -zcvf /backup/palworld-${DATE}.tgz ${PALDIR}/Saved ${PALDIR}/Binaries
fi

if [ "${DELETE_OLD_BACKUPS,,}" = true ]; then
	LINES="-${OLD_BACKUP_DAYS}"
	ls -d -1tr /backup/* | head -n ${LINES} | xargs -d '\n' rm -f
fi