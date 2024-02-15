#!/bin/bash
export WINEDEBUG=-all

steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

if [ ! -d "$WINEPREFIX" ]; then
  echo ""
  echo "Initializing Wine configuration"
  echo ""
  wineboot --init && wineserver -w
fi

if [ ! -f /app/steamcmd.exe ]; then
  echo ""
  echo "Downloading SteamCmd for Windows"
  echo ""
  wget -O /app/steamcmd.zip ${steamcmd_url}
  unzip /app/steamcmd.zip*
  rm -rf /app/steamcmd.zip*
  echo ""
  echo "Installing Palworld Server..."
  echo "Container might need to be restarted when done"
  echo ""
fi

# Install Visual C++ Runtime
/usr/bin/winetricks \
--optout -f -q vcrun2022 && \
wineserver -w

# Install/Update Palworld Server
echo ""
echo "Updating and Validating Palworld Server"
echo ""
/usr/bin/wine \
/app/steamcmd.exe \
+login anonymous +app_update 2394010 validate +quit && \
wineserver -w

# Start Palworld Server
echo ""
echo "Starting Palword Server"
echo ""
/usr/bin/wine \
/app/steamapps/common/PalServer/Pal/Binaries/Win64/PalServer-Win64-Test-Cmd.exe \
-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
