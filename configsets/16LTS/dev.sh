#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing config set dev for 16 LTS${RESET_COLOR}"

apt_install "default-jdk"

apt_install "golang-go"

apt_install "doxygen"

apt_install "graphviz"

apt_install "cmake"

deb_install "forticlient-sslvpn" \
    "https://hadler.me/files/forticlient-sslvpn_4.4.2333-1_amd64.deb"

file_load_to_opt "qt" \
    "http://download.qt.io/official_releases/online_installers/qt-unified-linux\
-x64-online.run"

tar_load_to_opt "jb_toolbox" \
    "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.11.4231.tar.gz"\
    "tar.gz"

apt_add_repository "ppa:webupd8team/java"
logged_command \
    "echo debconf shared/accepted-oracle-license-v1-1 select true | \
    sudo debconf-set-selections"
logged_command \
    "echo debconf shared/accepted-oracle-license-v1-1 seen true | \
    sudo debconf-set-selections"
apt_install "java-common"
apt_install "oracle-java8-installer"

logged_command \
    "curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash --" &&
    {
        apt_install "nodejs"
        apt_install "build-essential"
        logged_command "sudo npm install -g grunt-cli"
        logged_command "sudo npm install -g typescript"
    }
