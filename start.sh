#!/bin/bash
export WINEDEBUG=-all

steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

if [ ! -d "$WINEPREFIX" ]; then
	printf "\e[0;32m%s\e[0m\n" "Initializing Wine configuration"
	wineboot --init && wineserver -w
fi

if [ ! -f /app/steamcmd.exe ]; then
	printf "\e[0;32m%s\e[0m\n" "Downloading SteamCmd for Windows"
	wget -O /app/steamcmd.zip ${steamcmd_url}
	unzip /app/steamcmd.zip*
	rm -rf /app/steamcmd.zip*
	printf "\e[0;32m%s\e[0m\n" "Installing Palworld Server...\nContainer might need to be restarted when done"
fi

# Install Visual C++ Runtime
/usr/bin/winetricks \
--optout -f -q vcrun2022 && \
wineserver -w

# Update Palworld Server
if [ "${UPDATE_ON_BOOT,,}" = true ]; then
	printf "\e[0;32m%s\e[0m\n" "Updating and Validating Palworld Server"
	/usr/bin/wine \
	/app/steamcmd.exe \
	+login anonymous +app_update 2394010 validate +quit && \
	wineserver -w
fi

# Start Palworld Server
printf "\e[0;32m%s\e[0m\n" "Starting Palword Server"
/usr/bin/wine \
/app/steamapps/common/PalServer/Pal/Binaries/Win64/PalServer-Win64-Test-Cmd.exe \
-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
