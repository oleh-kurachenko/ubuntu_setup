#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}#    installing universal programs & tools${RESET_COLOR}"

apt_action "install gdebi"

apt_action "install linuxbrew-wrapper"

apt_action "install python-pip"

apt_action "install vim-gnome"

apt_action "install tree"

apt_action "install openssh-server"

apt_action "install curl"

curl_node_shline="curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash --"
echo -e "${BOLD_BLUE}#    $curl_node_shline...${RESET_COLOR}"
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -- &&
    {
        echo -e "${BOLD_GREEN}#    $curl_node_shline: OK!${RESET_COLOR}"
        apt_action "install nodejs";
        apt_action "install build-essential";
        bash_action "npm install -g grunt-cli";
        bash_action "npm install -g typescript";
    } ||
    {
        echo -e "${BOLD_RED}#    $curl_node_shline: FAILED!${RESET_COLOR}";
        common_errors_list="${common_errors_list}  $curl_node_shline: FAILED!\n";
    }

apt_action "install default-jre"
apt_action "install golang-go"

git config --global alias.lg "log --oneline --decorate --graph --all" 

# exit message
echo -e "${BOLD_CYAN}#    universal programs & tools: ${BOLD_GREEN}INSTALLED!${RESET_COLOR}"
