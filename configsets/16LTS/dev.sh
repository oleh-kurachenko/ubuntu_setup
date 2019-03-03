#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing config set dev for 16 LTS${RESET_COLOR}"

deb_install "forticlient-sslvpn" \
    "https://hadler.me/files/forticlient-sslvpn_4.4.2333-1_amd64.deb"

file_load_to_opt "qt" \
    "http://download.qt.io/official_releases/online_installers/qt-unified-linux\
-x64-online.run"

tar_load_to_opt "jb_toolbox" \
    "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.11.4231.tar.gz"\
    "tar.gz"
