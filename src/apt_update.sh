#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Updating apt dependencies${RESET_COLOR}"

logged_command "sudo apt-get update --yes"

logged_command "sudo apt-get upgrade --yes"

logged_command "sudo apt-get autoremove --yes"
