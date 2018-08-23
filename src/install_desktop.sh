#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing desktop programs & tools${RESET_COLOR}"

deb_install "google-chrome-stable" \
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# installing UI tools & themes
apt_install "unity-tweak-tool"

apt_add_repository "ppa:daniruiz/flat-remix"
apt_add_repository "ppa:noobslab/themes"

apt_install "flat-remix"
apt_install "arc-theme"

apt_install "default-jdk"

apt_install "inkscape"

apt_install "vlc"

