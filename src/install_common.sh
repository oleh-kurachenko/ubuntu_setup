#!/usr/bin/env bash

source constants.sh

# welcome message
echo -e "${BOLD_CYAN}#    installing universal programs & tools${RESET_COLOR}"

apt_action "install gdebi"
apt_action "install linuxbrew-wrapper"
apt_action "install python-pip"

apt_action "install vim-gnome"

apt_action "install tree"

apt_action "install install openssh-server"

apt_action "install nodejs"
apt_action "install npm"
apt_action "install build-essential"

apt_action "install default-jre"
apt_action "install golang-go"

# exit message
echo -e "${BOLD_CYAN}#    universal programs & tools: ${BOLD_GREEN}INSTALLED!${RESET_COLOR}"
