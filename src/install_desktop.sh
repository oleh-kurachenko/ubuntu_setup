#!/usr/bin/env bash

source constants.sh

# welcome message
echo -e "${BOLD_CYAN}#    installing desktop programs & tools${RESET_COLOR}"

# installing Google Chrome
echo -e "${BOLD_BLUE}Installing Google Chrome...${RESET_COLOR}"
bash_action "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
bash_action "dpkg -i google-chrome-stable_current_amd64.deb"
bash_action "rm -f google-chrome-stable_current_amd64.deb"
echo -e "${BOLD_GREEN}Installig Google Chrome: OK!${RESET_COLOR}"

# installing UI tools & themes
apt_action "install unity-tweak-tool"

bash_action "add-apt-repository ppa:daniruiz/flat-remix --yes"
bash_action "add-apt-repository ppa:noobslab/themes --yes"

source apt_update.sh

apt_action "install flat-remix"
apt_action "install arc-theme"

apt_action "install default-jdk"

apt_action "install inkscape"

apt_action "install vlc"

# exit message
echo -e "${BOLD_CYAN}#    desktop programs & tools: ${BOLD_GREEN}INSTALLED!${RESET_COLOR}"