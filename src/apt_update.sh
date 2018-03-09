#!/usr/bin/env bash

source constants.sh

# welcome message
echo -e "${BOLD_CYAN}#    updating apt dependencies${RESET_COLOR}"

apt_action update
apt_action upgrade
apt_action autoremove

# exit message
echo -e "${BOLD_CYAN}#    apt dependencies: ${BOLD_GREEN}UPDATED!${RESET_COLOR}"