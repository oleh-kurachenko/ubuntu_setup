#!/usr/bin/env python3

##
#  @file main.py
#  @copyright (C) 2019 by Oleh Kurachenko.
#  See LICENCE file at the root of repository
#  @author Oleh Kurachenko <oleh.kurachenko@gmail.com>
#  @date Created 2019-03-03
#
#  @see Author's
#  <a href="gitlab.com/oleh.kurachenko">GitLab</a>
#  @see Author's
#  <a href="linkedin.com/in/oleh-kurachenko-6b025b111">LinkedIn</a>
#

import os
import sys
import subprocess
import lsb_release
import tempfile
import json
from colorama import Fore, Style
from typing import Dict


##
#  Check whether commands can be executed under sudo (password was entered
#  before script invocation)
#
def sudo_available() -> bool:
    run_result = subprocess.run(
        "sudo -n ls",
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        cwd="/tmp")
    return run_result.returncode == 0


def get_configsets_path(source: str) -> str:
    if '@' in source or source[:4] == "http":
        print(f"{Fore.BLUE}Assume source is git repository pointed by " +
            f"{Fore.CYAN}{Style.BRIGHT}{source}{Style.RESET_ALL}")
        tmp_directory = tempfile.mkdtemp()
        subprocess.run(
            f"git clone {source} {tmp_directory}/configsets",
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True).check_returncode()
        return f"{tmp_directory}/configsets"
    if source[:1] == '/' or source[:2] == './' or source[:3] == "../":
        print(f"{Fore.BLUE}Assume source is already existing path " +
              f"{Fore.CYAN}{Style.BRIGHT}{source}{Style.RESET_ALL}")
        if not os.path.isdir(source):
            raise NotADirectoryError(source)
        return os.path.abspath(source)
    if source == 'default':
        print(f"{Fore.BLUE}Source is default{Style.RESET_ALL}")
        run_result = subprocess.run(
            "git config --get remote.origin.url",
            shell=True,
            stdout=subprocess.PIPE,
            cwd=os.path.dirname(__file__)
        )
        run_result.check_returncode()
        repo_url = run_result.stdout.decode("utf-8").strip()
        source_repo_url = repo_url[:repo_url.rfind('/')] + \
            "/linux_os_configsets.git"

        return get_configsets_path(source_repo_url)
    raise RuntimeError("Source is not good.")


# TODO finish greeting message.
def print_greeting():
    print(f"{Fore.YELLOW}TODO: finish greeting message...{Style.RESET_ALL}")


def execute_command(
        command: str,
        index: int,
        count: int,
        depth: str = "  ") -> bool:
    print(f"{Fore.BLUE}{depth}- ({index}/{count}) {command}... " +
        f"{Style.RESET_ALL}")
    run_result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    if run_result.returncode == 0:
        print(f"{Fore.BLUE}{depth}- ({index}/{count}) {command}: " +
            f"{Fore.GREEN + Style.BRIGHT}OK{Style.RESET_ALL}")
        return True

    print(f"{Fore.YELLOW}{Style.BRIGHT}stdout + stderr:{Style.NORMAL}" +
        f"{run_result.stdout.decode('utf-8')}{Style.RESET_ALL}")
    print(f"{Fore.BLUE}{depth}- ({index}/{count}) {command}: " +
        f"{Fore.RED + Style.BRIGHT}FAILED!{Style.RESET_ALL}")
    return False


def add_apt_repository(
        repository_name: str,
        index: int,
        count: int) -> bool:
    return execute_command(
        f"sudo -n add-apt-repository {repository_name} -y", index, count)


def apt_install(
        package_name: str,
        index: int,
        count: int) -> bool:
    return execute_command(
        f"sudo -n apt install {package_name} -y", index, count)


def deb_install(
        package_name: str,
        package_url: str,
        index: int,
        count: int) -> bool:
    run_result = subprocess.run(
        f"dpkg -l | grep {package_name}",
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        shell=True)
    if run_result.returncode == 0:
        print(f"{Fore.BLUE}  - ({index}/{count}) Deb package {Style.BRIGHT}" +
            f"{package_name}: {Style.NORMAL}{Fore.BLUE + Style.BRIGHT}" +
            f"already installed{Style.RESET_ALL}")
        return True

    print(f"{Fore.BLUE}  - ({index}/{count}) Deb package {Style.BRIGHT}" +
          f"{package_name}{Style.NORMAL}...{Style.RESET_ALL}")

    temporary_directory: str = tempfile.mkdtemp()
    deb_file_path: str = f"{temporary_directory}/{package_name}.deb"

    no_issues: bool = True

    no_issues = execute_command(
        f"wget '{package_url}' -O '{deb_file_path}'", 1, 2, "    ")
    if no_issues:
        no_issues = execute_command(
            f"sudo gdebi '{deb_file_path}' --n", 2, 2, "    ")

    if not no_issues:
        print(f"{Fore.BLUE}  - ({index}/{count}) Deb package {Style.BRIGHT}" +
              f"{package_name}: {Style.NORMAL}{Fore.RED + Style.BRIGHT}" +
              f"FAILED{Style.RESET_ALL}")
        return False

    print(f"{Fore.BLUE}  - ({index}/{count}) Deb package {Style.BRIGHT}" +
          f"{package_name}: {Style.NORMAL}{Fore.GREEN + Style.BRIGHT}" +
          f"Success{Style.RESET_ALL}")
    return True


def execute_configset(
        search_dir: str,
        configset: str,
        index: int,
        count: int,
        sudo_available: bool):
    configset_file_path: str = f"{search_dir}/{configset}.json"

    if not os.path.isfile(configset_file_path):
        print(f"{Fore.RED}Cannot execute configset {Style.BRIGHT}{configset}" +
              f" ({index}/{count}):{Style.RESET_ALL}")
        print(f"{Fore.RED}- No such file: {Style.BRIGHT}{configset_file_path}" +
            f"{Style.RESET_ALL}")
        return

    print(f"{Fore.BLUE}Executing configset {Style.BRIGHT}{configset}" +
        f" ({index}/{count}){Style.NORMAL}...{Style.RESET_ALL}")

    json_file = open(configset_file_path)
    json_data = json.load(json_file)
    json_file.close()

    configset_no_issues: bool = True

    # Pre-install commands

    if sudo_available and 'pre-install-commands' in json_data:
        print(f"{Fore.BLUE}- Pre-install commands...{Style.RESET_ALL}")

        no_issues: bool = True

        commands = json_data['pre-install-commands']
        for i, command in enumerate(commands):
            no_issues = execute_command(command, i + 1, len(commands))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- Pre-install commands: " +
                f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- Pre-install commands: " +
                f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # apt repositories

    if sudo_available and configset_no_issues \
            and 'apt-repositories' in json_data:
        print(f"{Fore.BLUE}- apt repositories...{Style.RESET_ALL}")

        no_issues: bool = True

        repository_names = json_data['apt-repositories']
        for i, repository_name in enumerate(repository_names):
            no_issues = add_apt_repository(
                repository_name, i + 1, len(repository_names))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- apt repositories: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- apt repositories: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # apt repositories

    if sudo_available and configset_no_issues \
            and 'apt-packages' in json_data:
        print(f"{Fore.BLUE}- apt packages...{Style.RESET_ALL}")

        no_issues: bool = True

        package_names = json_data['apt-packages']
        for i, package_name in enumerate(package_names):
            no_issues = apt_install(
                package_name, i + 1, len(package_names))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- apt packages: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- apt packages: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # deb repositories

    if sudo_available and configset_no_issues \
            and 'deb-packages' in json_data:
        print(f"{Fore.BLUE}- deb packages...{Style.RESET_ALL}")

        no_issues: bool = True

        packages = json_data['deb-packages']
        for i, package in enumerate(packages):
            no_issues = deb_install(
                package['name'], package['url'], i + 1, len(packages))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- deb packages: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- deb packages: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # Install commands

    if sudo_available and configset_no_issues \
            and 'install-commands' in json_data:
        print(f"{Fore.BLUE}- Install commands...{Style.RESET_ALL}")

        no_issues: bool = True

        commands = json_data['install-commands']
        for i, command in enumerate(commands):
            no_issues = execute_command(command, i + 1, len(commands))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- Install commands: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- Install commands: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # Post-install commands

    if configset_no_issues and 'post-install-commands' in json_data:
        print(f"{Fore.BLUE}- Post-install commands...{Style.RESET_ALL}")

        no_issues: bool = True

        commands = json_data['post-install-commands']
        for i, command in enumerate(commands):
            no_issues = execute_command(command, i + 1, len(commands))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- Post-install commands: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            configset_no_issues = False
        else:
            print(f"{Fore.BLUE}- Post-install commands: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    # Done

    if configset_no_issues:
        print(f"{Fore.BLUE}Executing configset {Style.BRIGHT}{configset}" +
            f" ({index}/{count}){Style.NORMAL}: {Fore.GREEN + Style.BRIGHT}" +
            f"Success!{Style.RESET_ALL}")
    else:
        print(f"{Fore.BLUE}Executing configset {Style.BRIGHT}{configset}" +
              f" ({index}/{count}){Style.NORMAL}: {Fore.RED + Style.BRIGHT}" +
              f"FAILED!{Style.RESET_ALL}")


if __name__ == "__main__":
    print_greeting()

    sudo_available: bool = sudo_available()
    print(f"{Fore.BLUE}Availability of sudo: " +
        f"{Fore.GREEN + Style.BRIGHT if sudo_available else ''}" +
        f"{sudo_available}{Style.RESET_ALL}")

    os_release: Dict[str, str] = lsb_release.get_os_release()
    print(f"{Fore.BLUE}Linux OS: {Fore.CYAN + Style.BRIGHT}" +
        f"{os_release['DESCRIPTION']}{Style.RESET_ALL}")

    if len(sys.argv) < 2:
        raise RuntimeError("PLAIN UPDATE NOT IMPLEMENTED!")

    configsets_path = get_configsets_path(sys.argv[1])
    print(f"{Fore.BLUE}Configsets root path: {Fore.CYAN + Style.BRIGHT}" +
          f"{configsets_path}{Style.RESET_ALL}")

    configsets_dir = \
        f"{configsets_path}/{os_release['ID']}/{os_release['RELEASE']}"
    if not os.path.isdir(configsets_dir):
        raise NotADirectoryError(configsets_dir)
    print(f"{Fore.BLUE}Configsets directory: {Fore.CYAN + Style.BRIGHT}" +
          f"{configsets_dir}{Style.RESET_ALL}")

    if len(sys.argv) == 2:
        print(f"{Fore.YELLOW}{Style.BRIGHT}No configsets given to CLI" +
            f"{Style.RESET_ALL}")
        exit(0)

    if sudo_available:
        print(f"{Fore.BLUE}- Global update commands...{Style.RESET_ALL}")

        no_issues: bool = True

        commands = [
            "sudo apt update",
            "sudo apt upgrade -y",
            "sudo apt autoremove -y"
        ]
        for i, command in enumerate(commands):
            no_issues = execute_command(command, i + 1, len(commands))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- Global update commands: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            exit(1)
        else:
            print(f"{Fore.BLUE}- Global update commands: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")

    for i, configset in enumerate(sys.argv[2:]):
        execute_configset(
            configsets_dir, configset, i + 1, len(sys.argv) - 2, sudo_available)

    if sudo_available:
        print(f"{Fore.BLUE}- Global update commands...{Style.RESET_ALL}")

        no_issues: bool = True

        commands = [
            "sudo apt update",
            "sudo apt upgrade -y",
            "sudo apt autoremove -y"
        ]
        for i, command in enumerate(commands):
            no_issues = execute_command(command, i + 1, len(commands))
            if not no_issues:
                break

        if not no_issues:
            print(f"{Fore.BLUE}- Global update commands: " +
                  f"{Fore.RED + Style.BRIGHT}FAILED{Style.RESET_ALL}")
            exit(1)
        else:
            print(f"{Fore.BLUE}- Global update commands: " +
                  f"{Fore.GREEN + Style.BRIGHT}Success{Style.RESET_ALL}")
