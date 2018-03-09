#!/usr/bin/env bash

source src/constants.sh

# welcome message
sudo echo -e "${BOLD_YELL}#    sudo passed (running on root)${RESET_COLOR}"
echo -e "${BOLD_CYAN}###  Setup tool for Ubuntu${RESET_COLOR}"
echo -e "${BOLD_CYAN}###     by Oleh Kurachenko${RESET_COLOR}"
echo -e "${BOLD_CYAN}###    aka okurache${RESET_COLOR}"
echo -e "${NBLD_CYAN}###  e-mail  oleh.kurachenko@gmail.com${RESET_COLOR}"
echo -e "${NBLD_CYAN}###  GitHub  https://github.com/OlehKurachenko${RESET_COLOR}"
echo -e "${NBLD_CYAN}###  rate&CV http://www.linkedin.com/in/oleh-kurachenko-6b025b111${RESET_COLOR}"

source src/apt_update.sh

#if [ "$1" == "desktop" ]; then
#    source src/install_common.sh
#
#fi
