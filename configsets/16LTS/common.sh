#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing config set common for 16 LTS${RESET_COLOR}"

logged_command \
    'git config --global alias.lg "log --oneline --decorate --graph --all"'

logged_command \
    "gsettings set org.gnome.desktop.input-sources sources \
     \"[('xkb', 'us'), ('xkb', 'ua'), ('xkb', 'ru')]\""