#!/usr/bin/env bash

# saving call directory path && changing directory to where files are located
call_directory="$(pwd)"
cd "$(dirname "$0")" || ( echo "failed to change directory, stop" ; exit 1 )

# color constants
BOLD_CYAN="\033[1;36m"
NBLD_CYAN="\033[36m"
BOLD_BLUE="\033[1;34m"
NBLD_BLUE="\033[34m"
BOLD_YELL="\033[1;33m"
BOLD_GREEN="\033[1;32m"
BOLD_RED="\033[1;31m"
RESET_COLOR="\033[0;0m"

# list of errors
common_errors_list=""

# run source, show proper error message if problems
source_comm() {
    source $1 ||
    {
        echo -e "${BOLD_RED}#    Failed to load $1${RESET_COLOR}";
        common_errors_list="${common_errors_list}  Failed to load $1"\n;
    }
}

# persorm bash action with proper cli comments
bash_action() {
    echo -e "${BOLD_BLUE}#    $1...${RESET_COLOR}"
    sudo $1 && echo -e "${BOLD_GREEN}#    $1: OK!${RESET_COLOR}" ||
    {
        echo -e "${BOLD_RED}#    $1: FAILED!${RESET_COLOR}";
        common_errors_list="${common_errors_list}  $1: FAILED!\n";
        echo -e "common list: ${common_errors_list}";
    }
    echo -e "common list: ${common_errors_list}"
}

# perform apt action with proper cli comments
apt_action() {
    bash_action "apt-get $1 --yes"
}

# welcome message
sudo echo -e "${BOLD_YELL}#    sudo passed (running root)${RESET_COLOR}"
echo -e "${BOLD_CYAN}"
echo -e "###  Setup tool for Ubuntu"
echo -e "###     by Oleh Kurachenko"
echo -e "###    aka okurache"
echo -e "###  e-mail  oleh.kurachenko@gmail.com"
echo -e "###  GitHub  https://github.com/OlehKurachenko"
echo -e "###  rate&CV http://www.linkedin.com/in/oleh-kurachenko-6b025b111${RESET_COLOR}"

source_comm "src/apt_update.sh"

if [ "$1" == "desktop" ];
then
    source_comm "src/install_common.sh"
    source_comm "src/install_desktop.sh"
    source_comm "src/apt_update.sh"
fi

if [ "$1" == "server" ];
then
    source_comm "src/install_common.sh"
    source_comm "src/install_server.sh"
    source_comm "src/apt_update.sh"
fi

echo -e "${BOLD_CYAN}###  Setting up FINISHED${RESET_COLOR}"
if [ "$common_errors_list" == "" ];
then
    echo -e "${BOLD_GREEN}###  All OK!${RESET_COLOR}"
else
    {
        echo -e "${BOLD_YELL}###  Problems during setup:${RESET_COLOR}";
        echo -e "${BOLD_RED}$common_errors_list${RESET_COLOR}";
    }
fi
