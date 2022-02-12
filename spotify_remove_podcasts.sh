#!/bin/sh

cd /var/lib/flatpak/app/com.spotify.Client/current/active/files/extra/share/spotify/Apps
unzip -p xpui.spa xpui.js | sed 's/,show,/,/' | sed 's/,episode"/"/' > xpui.js
cp xpui.spa xpui.spa.bak
zip xpui.spa xpui.js
cd -
