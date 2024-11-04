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
tar -xzf /tmp/master.tar.gz -C "$HOME"/.icons --strip-components=1
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"

# gnome terminal
TERMINAL_PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[]'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-theme-transparency false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ background-transparency-percent 20
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ background-color '#141617'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$TERMINAL_PROFILE_ID/ foreground-color '#D3D7CF'

# background image
rm -f "${HOME}/Pictures/background.png"
wget 'https://initiate.alphacoders.com/download/images6/1322318/jpeg' -O "${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.background picture-uri "file:///${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///${HOME}/Pictures/background.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///${HOME}/Pictures/background.jpg"

# additional programs
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
sudo apt install /tmp/google-chrome-stable_current_amd64.deb -y
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -P /tmp
sudo apt install /tmp/teamviewer_amd64.deb -y

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env && rustup update

# favorite apps
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'google-chrome.desktop', 'telegram-desktop_telegram-desktop.desktop', 'discord_discord.desktop']"

# build Google Test
cd /usr/src/gtest && sudo cmake CMakeLists.txt && sudo make && sudo cp lib/*.a /usr/lib

# install Docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
