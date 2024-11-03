#!/bin/bash

set -euxo pipefail

# git configs
git config --global user.name "Oleh Kurachenko"
git config --global user.email "oleh.kurachenko@gmail.com"
git config --global alias.lg "log --oneline --decorate --graph --all"

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ua'), ('xkb', 'ru')]"

# icons - flat-remix
mkdir "$HOME"/.icons
wget https://github.com/daniruiz/flat-remix/archive/refs/heads/master.tar.gz -P /tmp/
tar -xzvf /tmp/master.tar.gz -C "$HOME"/.icons -strip-components=1
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"


