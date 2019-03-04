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
verbose_log=false
temporary_file_prefix="oleh_kurachenko_ubuntu_setup_script_temporary_file_"
tmp_directory="/tmp"
opt_directory="/opt"
configsets_path="configsets"

# cleaning old and creating new log files
rm -f ${tmp_directory}/${temporary_file_prefix}*
console_log_file="${tmp_directory}/${temporary_file_prefix}console_log.txt"
error_log_file="${tmp_directory}/${temporary_file_prefix}error_log.txt"
touch "$console_log_file"
touch "$error_log_file"

# setting /opt view note
opt_directories_to_check=()

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
    go run src/main.go execute $1
    return $?
}

# Script body
#-------------------------------------------------------------------------------

# parsing command line arguments

configsets=()

i=1;
while [ "$i" -le "$#" ]
do
    if [ ${!i} == "-s" ] || [ ${!i} == "--configset" ]
    then
        i=$((i + 1))
        configsets+=(${!i})
    elif [ ${!i} == "-v" ] || [ ${!i} == "--verbose-log" ]
    then
        verbose_log=true
    else
        echo -e "${BOLD_RED}Unknown option: ${!i}${RESET_COLOR}"
        exit 1
    fi
    i=$((i + 1))
done

# welcome message
sudo echo -e "${BOLD_GREEN}Sudo passed (running root)${RESET_COLOR}"
if [ $? -ne 0 ]
then
    echo -e "${BOLD_RED}Sudo not passed (exit)${RESET_COLOR}"
    exit 1
fi
echo -e "${BOLD_CYAN}"
echo -e "Setup tool for Ubuntu"
echo -e "    by Oleh Kurachenko"
echo -e "    aka okurache"
echo -e "e-mail  oleh.kurachenko@gmail.com"
echo -e "GitHub  https://github.com/OlehKurachenko"
echo -e "rate&CV http://www.linkedin.com/in/oleh-kurachenko-6b025b111\
${RESET_COLOR}"

# TODO finish intergation seciton
if [ -z ${GOPATH+x} ]
then
    sudo apt-get install golang-go -y
    sudo apt-get install git -y
    export GOPATH=$HOME/go
    source ~/.bashrc
fi
go get github.com/fatih/color

logged_source "src/apt_update.sh"

for configset in "${configsets[@]}"
do
    logged_source "${configsets_path}/${ubuntu_version}/${configset}.sh"
    go run src/main.go configsset "${configset}" \
        "${configsets_path}/${ubuntu_version}/${configset}.json"
done

if [ "${#configsets[@]}" -ne 0 ]
then
    logged_source "src/apt_update.sh"
fi

echo -e "${BOLD_CYAN}Setting up FINISHED${RESET_COLOR}"

if [ -s ${error_log_file} ]
then
    echo -e "${BOLD_RED}Errors occured during the setup${RESET_COLOR}"
    echo -e "${BOLD_RED}Error Log:"
    cat ${error_log_file}
    echo -e "${RESET_COLOR}"
else
    echo -e "${BOLD_GREEN}All OK!${RESET_COLOR}"
fi

echo -e "${BOLD_BLUE}Logs can be found here: ${NBLD_BLUE}${console_log_file}\
${RESET_COLOR}"
if [ ${#opt_directories_to_check[@]} -ne 0 ]
then
    echo -e "${BOLD_YELL}Check ${opt_directory} to install programs which \
requires manual installation${RESET_COLOR}"
    echo -e "${BOLD_YELL}The following directories insize of ${opt_directory} \
should be checked:${RESET_COLOR}"
    for program_directory in "${opt_directories_to_check[@]}"
    do
        echo -e "${BOLD_YELL}- ${program_directory}${RESET_COLOR}"
    done
fi

if [ -s ${error_log_file} ]
then
    exit 1
else
    exit 0
fi
