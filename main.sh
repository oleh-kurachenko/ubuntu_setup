#!/usr/bin/env bash

# Configuring settings
#-------------------------------------------------------------------------------

# saving call directory path && changing directory to where files are located
call_directory="$(pwd)"
cd "$(dirname "$0")" || ( echo "failed to change directory, stop" ; exit 1 )

# color constants
BOLD_CYAN="\033[1;36m"
NBLD_CYAN="\033[0;36m"
BOLD_BLUE="\033[1;34m"
NBLD_BLUE="\033[0;34m"
BOLD_YELL="\033[1;33m"
BOLD_GREEN="\033[1;32m"
BOLD_RED="\033[1;31m"
NBLD_RED="\033[0;31m"
RESET_COLOR="\033[0;0m"

# setting configuration constants with default values
ubuntu_version="16LTS"
update_software=true
temporary_file_prefix="oleh_kurachenko_ubuntu_setup_script_temporary_file_"
tmp_directory="/tmp"

# cleaning old and creating new log files
rm -f ${tmp_directory}/${temporary_file_prefix}*
console_log_file="${tmp_directory}/${temporary_file_prefix}console_log.txt"
error_log_file="${tmp_directory}/${temporary_file_prefix}error_log.txt"
stdout_log_file="${tmp_directory}/${temporary_file_prefix}stdout_log.txt"
stderr_log_file="${tmp_directory}/${temporary_file_prefix}stderr_log.txt"
touch "$console_log_file"
touch "$error_log_file"
touch "$stdout_log_file"
touch "$stderr_log_file"

# Common methods
#-------------------------------------------------------------------------------

# Takes filename of sh script as parameter and run this script
# $1: script filename
logged_source() {
    source $1 || {
        echo -e "${BOLD_RED}Failed to load $1${RESET_COLOR}";
        echo -e "Failed to load $1" >> ${error_log_file}
    }
}

# Takes command and execute it, checks error code and writes logs
# $1: command (if more then one, should be a block)
# returns exit code: 0 if all ok, 1 otherwise
logged_command() {
    echo -n "" > "$stdout_log_file"
    echo -n "" > "$stderr_log_file"
    echo -e "${BOLD_BLUE}$1...${RESET_COLOR}"
    echo -e "$ $1" >> "$console_log_file"
    eval $1 1> "$stdout_log_file" 2> "$stderr_log_file"
    if [ $? -eq 0 ]
    then
        echo -e "${BOLD_BLUE}$1: ${BOLD_GREEN}OK!${RESET_COLOR}"
        cat "$stdout_log_file" >> "$console_log_file"
        return 0
    else
        echo -e "${BOLD_RED}$1: FAIL!${RESET_COLOR}"
        cat "$stdout_log_file" >> "$console_log_file"
        cat "$stderr_log_file" >> "$console_log_file"
        echo -e "Fail in: $1" >> "$error_log_file"
        echo -e "Output:" >> "$error_log_file"
        cat "$stdout_log_file" >> "$error_log_file"
        echo -e "Error output:" >> "$error_log_file"
        cat "$stderr_log_file" >> "$error_log_file"
        return 1
    fi
}

# Takes package name and installs it via apt-get
# $1: package name
# returns exit code: 0 if all ok, 1 otherwise
apt_install() {
    logged_command "sudo apt-get install $1 --yes"
    return $?
}

# Takes repository name and adds it to apt repositories
# $1: repository name
# returns exit code: 0 if all ok, 1 otherwise
apt_add_repository() {
    logged_command "sudo add-apt-repository $1 --yes" &&
    logged_command "sudo apt-get update --yes"
    return $?
}

# Takes package name and URL of .deb file. If package with given name is not
# installed, .deb file is being downloaded & installed
# $1: package name
# $2: .deb file URL
# return exit code: 0 if all ok, 1 otherwise
deb_install() {
    dpkg -l | grep $1 1> /dev/null 2> /dev/null
    if [ $? -eq 0 ]
    then
        echo -e "${BOLD_GREEN}$1 already installed${RESET_COLOR}"
        return 0
    else
        logged_command "sudo wget $2 -O ${tmp_directory}/$1.deb" &&
        logged_command "sudo gdebi ${tmp_directory}/$1.deb --n" && {
            echo -e "${BOLD_GREEN}$1 successfully installed"
            return 0
        } || {
            echo -e "${BOLD_RED}failed to install $1"
            return 1
        }
    fi
}

# Script body
#-------------------------------------------------------------------------------

# welcome message
sudo echo -e "${BOLD_GREEN}Sudo passed (running root)${RESET_COLOR}"
echo -e "${BOLD_CYAN}"
echo -e "Setup tool for Ubuntu"
echo -e "    by Oleh Kurachenko"
echo -e "    aka okurache"
echo -e "e-mail  oleh.kurachenko@gmail.com"
echo -e "GitHub  https://github.com/OlehKurachenko"
echo -e "rate&CV http://www.linkedin.com/in/oleh-kurachenko-6b025b111\
${RESET_COLOR}"

logged_source "src/apt_update.sh"

if [ "$1" == "desktop" ];
then
    logged_source "src/install_common.sh"
    logged_source "src/install_desktop.sh"
    logged_source "src/apt_update.sh"
fi

if [ "$1" == "server" ];
then
    logged_source "src/install_common.sh"
    logged_source "src/install_server.sh"
    logged_source "src/apt_update.sh"
fi

echo -e "${BOLD_CYAN}Setting up FINISHED${RESET_COLOR}"

if [ -s ${error_log_file} ]
then
    echo -e "${BOLD_RED}Errors occured during the setup${RESET_COLOR}"
    echo -e "${BOLD_RED}Error Log:${NBLD_RED}"
    cat ${error_log_file}
    echo -e "${RESET_COLOR}"
else
    echo -e "${BOLD_GREEN}All OK!${RESET_COLOR}"
fi
