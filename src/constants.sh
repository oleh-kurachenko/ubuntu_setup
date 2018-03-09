#!/usr/bin/env bash

# color constants
BOLD_CYAN="\033[1;36m"
NBLD_CYAN="\033[36m"
BOLD_BLUE="\033[1;34m"
NBLD_BLUE="\033[34m"
BOLD_YELL="\033[1;33m"
BOLD_GREEN="\033[1;32m"
RESET_COLOR="\033[0;0m"

# perform apt action with proper cli comments
apt_action() {
    echo -e "${BOLD_BLUE}#    apt-get $1...${RESET_COLOR}"
    sudo apt-get $1 --yes
    echo -e "${BOLD_GREEN}#    apt-get $1: OK!${RESET_COLOR}"
}
