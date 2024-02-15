#!/bin/bash
export WINEDEBUG=-all
steamcmd_exe="/app/steamcmd.exe"
winecmd="/usr/bin/wine"

if [ ! -d "${WINEPREFIX}" ]; then
	printf "\e[0;32m%s\e[0m\n" "Initializing Wine configuration"
	wineboot --init && wineserver -w
fi

# Install steamcmd executable
if [ ! -f "${steamcmd_exe}" ]; then
	steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
	printf "\e[0;32m%s\e[0m\n" "Downloading SteamCmd for Windows"
	curl -fsSLO ${steamcmd_url}
	unzip /app/steamcmd.zip* -d /app
	rm -rf steamcmd.zip*
fi

# Install Visual C++ Runtime
if [ "${WINETRICKS_ON_BOOT,,}" = true ]; then
	printf "\e[0;32m%s\e[0m\n" "Installing Visual C++ Runtime 2022"
	trickscmd=("/usr/bin/winetricks")
	trickscmd+=("--optout -f -q vcrun2022")
	echo "${trickscmd[*]}"
	"${trickscmd[@]}"
fi

# Update Palworld Server
if [ "${UPDATE_ON_BOOT,,}" = true ]; then
	printf "\e[0;32m%s\e[0m\n" "Updating and Validating Palworld Server"
	startsteam=("${winecmd}")
	startsteam+=("${steamcmd_exe}")
	startsteam+=("+login anonymous +app_update 2394010 validate +quit")
	echo "${startsteam[*]}"
	"${startsteam[@]}"
	wineserver -w
fi

# Start Palworld Server
printf "\e[0;32m%s\e[0m\n" "Starting Palword Server"
startcmd=("${winecmd}")
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
"${startcmd[@]}"
