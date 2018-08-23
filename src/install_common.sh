#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing universal programs & tools${RESET_COLOR}"

apt_install "gdebi"

apt_install "python-pip"

apt_install "vim-gnome"

apt_install "tree"

apt_install "openssh-server"

apt_install "curl"

logged_command \
    "curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash --" &&
    {
        apt_install "nodejs"
        apt_install "build-essential"
        logged_command "sudo npm install -g grunt-cli"
        logged_command "sudo npm install -g typescript"
    }

apt_install "default-jre"
apt_install "golang-go"

logged_command \
 'git config --global alias.lg "log --oneline --decorate --graph --all"'

