#!/bin/bash

set -euxo pipefail

# git configs
git config --global user.name "Oleh Kurachenko"
git config --global user.email "oleh.kurachenko@gmail.com"
git config --global alias.lg "log --oneline --decorate --graph --all"

# gnome configs
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ua'), ('xkb', 'ru')]"
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'
gsettings set org.gnome.desktop.interface cursor-size 18
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize:'
gsettings set org.gnome.mutter workspaces-only-on-primary false

# gnome desktop
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 44
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-format 12h
gsettings set org.gnome.desktop.interface show-battery-percentage true

# icons - flat-remix
mkdir "$HOME"/.icons
wget https://github.com/daniruiz/flat-remix/archive/refs/heads/master.tar.gz -P /tmp/
tar -xzvf /tmp/master.tar.gz -C "$HOME"/.icons --strip-components=1
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"

# gnome terminal
TERMINAL_PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[]'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-theme-transparency false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ background-transparency-percent 20
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ background-color '#141617'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ foreground-color '#D3D7CF'

#background
rm -f "${HOME}/Pictures/background.png"
wget 'https://initiate.alphacoders.com/download/images6/1322318/jpeg' -O "${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.background picture-uri "file:///${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri-dark "file:///${HOME}/Pictures/background.jpg"
