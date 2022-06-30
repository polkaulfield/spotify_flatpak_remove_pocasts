#!/bin/sh
# shellcheck disable=SC2094
# Above directive is because we're not actually operating on the same file.
set -eu

# Make sure required programs are available.
for dep in unzip zip sed; do if ! [ -x "$(command -v "$dep")" ]; then
	printf "This script requires %s; please install it.\n" "$dep"
	exit 1
fi; done

# Determine which Spotify to operate on.
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -e "$XDG_DATA_HOME/flatpak/app/com.spotify.Client" ]; then
	printf "Operating on per-user installation.\n"
	target="$XDG_DATA_HOME/flatpak/app/com.spotify.Client"
elif [ -e "/var/lib/flatpak/app/com.spotify.Client" ]; then
	if [ "$(id -u)" -gt 0 ]; then
		printf "Found system-wide installation as normal user; invoking sudo.\n"
		exec sudo -k "$0"
	else
		printf "Operating on system-wide installation.\n"
		target="/var/lib/flatpak/app/com.spotify.Client"
	fi
else
	printf "No Flatpak Spotify installation found; exiting.\n"
	exit 1
fi

# Actually do the thing!
cd "$target/current/active/files/extra/share/spotify/Apps"
unzip -p xpui.spa xpui.js | sed 's/withQueryParameters(e){return this.queryParameters=e,this}/withQueryParameters(e){return this.queryParameters=(e.types?{...e, types: e.types.split(",").filter(_ => !["episode","show"].includes(_)).join(",")}:e),this}/' > xpui.js
cp xpui.spa xpui.spa.bak
zip xpui.spa xpui.js
