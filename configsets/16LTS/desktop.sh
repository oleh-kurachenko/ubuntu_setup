#!/usr/bin/env bash

# welcome message
echo -e "${BOLD_CYAN}Installing desktop programs & tools${RESET_COLOR}"

apt_install "inkscape"

apt_install "gimp"

apt_install "vlc"

deb_install "google-chrome-stable" \
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

deb_install "skypeforlinux" \
    "https://go.skype.com/skypeforlinux-64.deb"

deb_install "discord" \
    "https://discordapp.com/api/download?platform=linux&format=deb"

logged_command "echo 'debconf opera-stable/add-deb-source select true' \
    | sudo debconf-set-selections" &&
logged_command "echo 'debconf opera-stable/add-deb-source seen true' \
    | sudo debconf-set-selections" &&
deb_install "opera-stable" \
    "https://www.opera.com/download/get/?id=44006&amp;location=415&amp;\
nothanks=yes&amp;sub=marine&utm_tryagain=yes"

logged_command \
    "echo \"deb https://dl.bintray.com/resin-io/debian stable etcher\" \
    | sudo tee /etc/apt/sources.list.d/etcher.list" &&
logged_command \
    "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
    379CE192D401AB61" &&
logged_command "sudo apt-get update --yes" &&
apt_install "etcher-electron"

tar_load_to_opt "telegram" "https://telegram.org/dl/desktop/linux" "tar.xz"

# installing & setuping UI tools & themes
#-------------------------------------------------------------------------------
apt_install "unity-tweak-tool"

apt_add_repository "ppa:daniruiz/flat-remix"
apt_add_repository "ppa:noobslab/themes"

apt_install "flat-remix"
apt_install "arc-theme"

#   common constants
border_color='#ffff00ff'
fill_color='#29992e50'

#   configuring launcher
logged_command \
    "gsettings set \
    org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ \
    background-color '#000000ff'"
logged_command \
    "gsettings set \
    org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ \
    icon-size 44"
logged_command \
    "gsettings set \
    org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ \
    launcher-opacity 0.8"

#   configuring menu bar
logged_command \
    "gsettings set com.canonical.indicator.datetime time-format '12-hour'"
logged_command \
    "gsettings set com.canonical.indicator.datetime show-seconds true"
logged_command \
    "gsettings set com.canonical.indicator.datetime show-date true"
logged_command \
    "gsettings set com.canonical.indicator.datetime show-day true"
logged_command \
    "gsettings set com.canonical.indicator.power show-percentage true"
logged_command \
    "gsettings set com.canonical.indicator.power show-time true"
logged_command \
    "gsettings set com.canonical.indicator.session show-real-name-on-panel true"

#   configuring workspaces
logged_command \
    "gsettings set \
    org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 4"
logged_command \
    "gsettings set \
    org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2"
logged_command \
    "gsettings set \
    org.compiz.expo:/org/compiz/profiles/unity/plugins/expo/ \
    selected-color '${border_color}'"

#   configuring grid
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    use-desktop-average-color false"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    outline-color '${border_color}'"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    fill-color '${fill_color}'"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    top-left-corner-action 7"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    top-edge-action 10"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    top-right-corner-action 9"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    left-edge-action 4"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    right-edge-action 6"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    bottom-left-corner-action 1"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    bottom-edge-action 2"
logged_command \
    "gsettings set org.compiz.grid:/org/compiz/profiles/unity/plugins/grid/ \
    bottom-right-corner-action 3"

#   window manager additional
logged_command \
    "gsettings set org.compiz.resize:/org/compiz/profiles/unity/plugins/resize/\
    mode 2"
logged_command \
    "gsettings set org.compiz.resize:/org/compiz/profiles/unity/plugins/resize/\
    use-desktop-average-color false"
logged_command \
    "gsettings set org.compiz.resize:/org/compiz/profiles/unity/plugins/resize/\
    border-color '${border_color}'"
logged_command \
    "gsettings set org.compiz.resize:/org/compiz/profiles/unity/plugins/resize/\
    fill-color '${fill_color}'"

#   Appearence
logged_command \
    "gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark-Solid'"
logged_command \
    "gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Dark'"
logged_command \
    "gsettings set org.gnome.desktop.interface cursor-size 18"
logged_command \
    "gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'"
logged_command \
    "gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Dark-Solid'"

#   wallpapers
background_filename="${HOME}/Pictures/background.jpg"
background_uri=\
"https://wallpaper.wiki/wp-content/uploads/2017/04/wallpaper.wiki-Nature-in-\
5cm-Per-Second-Anime-Wallpaper-PIC-WPD006029.jpg"
logged_command \
    "rm -f ${background_filename}"
logged_command \
    "wget '${background_uri}' -O ${background_filename}" &&
logged_command \
    "gsettings set org.gnome.desktop.background picture-uri \
    file://${background_filename}"

#   privacy settings
logged_command \
    "gsettings set org.gnome.desktop.privacy report-technical-problems true"

