#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}#    installing server programs & tools${RESET_COLOR}"

apt_action "install tmux"

# exit message
echo -e "${BOLD_CYAN}#    server programs & tools: ${BOLD_GREEN}INSTALLED!${RESET_COLOR}"
