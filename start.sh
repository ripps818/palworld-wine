#!/bin/bash
export WINEDEBUG=-all


if [ ! -d "$WINEPREFIX" ]; then
	printf "\e[0;32m%s\e[0m\n" "Initializing Wine configuration"
	wineboot --init && wineserver -w
fi

# Install steamcmd executable
if [ ! -f /app/steamcmd.exe ]; then
	steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
	printf "\e[0;32m%s\e[0m\n" "Downloading SteamCmd for Windows"
	wget -O /app/steamcmd.zip ${steamcmd_url}
	unzip /app/steamcmd.zip*
	rm -rf /app/steamcmd.zip*
	printf "\e[0;32m%s\e[0m\n" "Installing Palworld Server...\nContainer might need to be restarted when done"
fi

if [ "${WINETRICKS_ON_BOOT,,}" = true ]; then
	# Install Visual C++ Runtime
	trickscmd=("/usr/bin/winetricks")
	trickscmd+=("--optout -f -q vcrun2022")
	echo "${trickscmd[*]}"
	exec "${trickscmd[@]}"
fi

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

startcmd=("/usr/bin/wine")
paldir="/app/steamapps/common/PalServer/Pal/Binaries/Win64"
palcmd="${paldir}/PalServer-Win64-Test-Cmd.exe"
startcmd+=("${palcmd}")

if ! fileExists "${startcmd[0]}"; then
    echo "Try restarting with UPDATE_ON_BOOT=true"
    exit 1
fi

if [ -n "${PORT}" ]; then
    startcmd+=("-port=${PORT}")
fi

if [ -n "${QUERY_PORT}" ]; then
    startcmd+=("-queryport=${QUERY_PORT}")
fi

if [ "${MULTITHREADING,,}" = true ]; then
	startcmd+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

if [ "${COMMUNITY,,}" = true ]; then
    startcmd+=("EpicApp=PalServer")
fi

echo "${startcmd[*]}"
exec "${startcmd[@]}"
