#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q shotcut | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/128x128/apps/org.shotcut.Shotcut.png
export DESKTOP=/usr/share/applications/org.shotcut.Shotcut.desktop
export DEPLOY_PIPEWIRE=1
export DEPLOY_SDL=1

# Deploy dependencies
quick-sharun \
	/usr/bin/shotcut           \
	/usr/share/shotcut         \
	/usr/bin/ffmpeg            \
	/usr/bin/ffprobe           \
	/usr/bin/melt*             \
	/usr/share/mlt*            \
	/usr/lib/libCuteLogger.so* \
	/usr/lib/frei0r-*          \
	/usr/lib/mlt-*             \
	/usr/lib/ladspa            \
	/usr/lib/librtaudio.so*    \
	/usr/lib/libsox_ng.so*

echo 'FREI0R_PATH=${SHARUN_DIR}/lib/frei0r-1'               >> ./AppDir/.env
echo 'MLT_PROFILES_PATH=${SHARUN_DIR}/share/mlt-7/profiles' >> ./AppDir/.env
echo 'MLT_PRESETS_PATH=${SHARUN_DIR}/share/mlt-7/presets'   >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
