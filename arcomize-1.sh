#!/bin/bash
#
# arcomize-1.sh  Author: Bryan Dodd
# git clone 
# Usage: sudo ./arcomize-1.sh
# command line arguments are valid, only catching 1 arguement
#
# Disclaimer: Author assumes no liability for any damage resulting from use, misuse, or any other crazy
#             idea somebody attempts using, incorporating, deconstructing, or anything else with this tool.

# revision
    revision="0.1.0"

# colors
    color_nocolor='\e[0m'
    color_black='\e[0;30m'
    color_light_grey='\e[0;37m'
    color_grey='\e[1;30m'
    color_red='\e[0;31m'
    color_light_red='\e[1;31m'
    color_green='\e[0;32m'
    color_light_green='\e[1;32m'
    color_brown='\e[0;33m'
    color_yellow='\e[1;33m'
    color_other_yellow='\e[1;93m'
    color_blue='\e[0;34m'
    color_light_blue='\e[1;34m'
    color_purple='\e[0;35m'
    color_light_purple='\e[1;35m'
    color_cyan='\e[0;36m'
    color_light_cyan='\e[1;36m'
    color_white='\e[1;37m'

# indicators
    greenplus='\e[1;32m[++]\e[0m'
    greenminus='\e[1;32m[--]\e[0m'
    greenstar='\e[1;32m[**]\e[0m'
    yellowstar='\e[1;93m[**]\e[0m'
    bluestar='\e[1;34m[**]\e[0m'
    cyanstar='\e[1;36m[**]\e[0m'
    redminus='\e[1;31m[--]\e[0m'
    redexclaim='\e[1;31m[!!]\e[0m'
    redstar='\e[1;31m[**]\e[0m'
    blinkwarn='\e[1;93m[\e[5;93m**\e[0m\e[1;93m]\e[0m'
    blinkexclaim='\e[1;31m[\e[5;31m!!\e[0m\e[1;31m]\e[0m'
    fourblinkexclaim='\e[1;31m[\e[5;31m!!!!\e[0m\e[1;31m]\e[0m'

# static files
    whisker_new="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/whiskermenu-7.rc"
    sublime_launcher="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/launcher-1/16325907731.desktop"
    firefox_launcher="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/launcher-12/16325911012.desktop"
    chrome_launcher="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/launcher-13/16325911153.desktop"
    user_term_launcher="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/launcher-14/16325912214.desktop"
    root_term_launcher="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/launcher-14/16325914395.desktop"
    ip_widget="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/genmon-17.rc"
    ip_script="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel-scripts/menu-ip.sh"
    net_widget="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/panel/netload-21.rc"

    panel_conf="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/xfconf/xfce4-panel.xml"

    kitty_conf="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/kitty/kitty.conf"


findUser=$(logname)

# terminal preference (kitty -or- alacritty)
termPref="kitty"

vm_install() {
    # For virtual machines only.

    pacman -Sy open-vm-tools --needed --noconfirm
    systemctl enable vmtoolsd.service
    echo -e "\n  $greenplus open-vm-tools : installed and enabled"
}

required_apps() {
    pacman -Q xmlstarlet > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        pacman -Sy xmlstarlet --needed --noconfirm
        echo -e "\n  $greenplus xmlstarlet : installed"
    fi
}

preferred_apps() {
    # A personal list of preferred applications.
    pacman -Q gedit > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        pacman -Sy gedit --noconfirm
        echo -e "\n  $greenplus gedit : installed"
    else
        echo -e "\n  $yellowstar gedit : already installed"
    fi
}

disable_power_mgmt() {
    # Set screen blanking / sleep to 0 and then disable power management entirely.
    # Values are zeroed out in the event that power management gets turned back on accidentally.

    # settings for USER
    userPowerConf="/home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml"
    cp $userPowerConf /home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.bak

    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-sleep']/@value" --value "0" $userPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-off']/@value" --value "0" $userPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='blank-on-ac']/@value" --value "0" $userPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-sleep']/@value" --value "0" $userPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-off']/@value" --value "0" $userPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='blank-on-battery']/@value" --value "0" $userPowerConf)
    userPowerDisabled=$(xmlstarlet sel -t -v "count(//property[@name='dpms-enabled'])" $userPowerConf)
    if [[ $userPowerDisabled -ne 1 ]]; then
        eval $(xmlstarlet edit -P -L -s "/channel[@name='xfce4-power-manager']/property[@name='xfce4-power-manager']" -t elem -n "propertyTemp" -v "" -i "//propertyTemp" -t attr -n "name" -v "dpms-enabled" -i "//propertyTemp" -t attr -n "type" -v "bool" -i "//propertyTemp" -t attr -n "value" -v "false" -r "//propertyTemp" -v "property" $userPowerConf)
    fi
    echo -e "\n  $greenstar power management : USER configured for zero timeout and disabled"

    # settings for ROOT
    rootPowerConf="/root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml"
    cp $rootPowerConf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.bak

    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-sleep']/@value" --value "0" $rootPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-off']/@value" --value "0" $rootPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='blank-on-ac']/@value" --value "0" $rootPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-sleep']/@value" --value "0" $rootPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-off']/@value" --value "0" $rootPowerConf)
    eval $(xmlstarlet edit -P -L --update "//property[@name='blank-on-battery']/@value" --value "0" $rootPowerConf)
    rootPowerDisabled=$(xmlstarlet sel -t -v "count(//property[@name='dpms-enabled'])" $rootPowerConf)
    if [[ $rootPowerDisabled -ne 1 ]]; then
        eval $(xmlstarlet edit -P -L -s "/channel[@name='xfce4-power-manager']/property[@name='xfce4-power-manager']" -t elem -n "propertyTemp" -v "" -i "//propertyTemp" -t attr -n "name" -v "dpms-enabled" -i "//propertyTemp" -t attr -n "type" -v "bool" -i "//propertyTemp" -t attr -n "value" -v "false" -r "//propertyTemp" -v "property" $rootPowerConf)
    fi
    echo -e "\n  $greenstar power management : ROOT configured for zero timeout and disabled"
}

xfce4_panel_mod() {
    # Set preferences for the xfce4 main panel

    ## move the panel to the top of the screen

    

    ##eval $(xfconf-query -c xfce4-panel -p /panels/panel-1/position -t string -s 'p=6;x=1488;y=17')
    #eval $(xmlstarlet edit -P -L --update "//property[@name='position']/@value" --value "p=6;x=1488;y=17" $panelFile)
    #echo -e "\n  $greenstar xfce4-panel : repositioned to top of screen"

    # download panel configs
    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-1
    eval wget $sublime_launcher -O /home/$findUser/.config/xfce4/panel/launcher-1/16325907731.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Sublime$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-12
    eval wget $firefox_launcher -O /home/$findUser/.config/xfce4/panel/launcher-12/16325911012.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Firefox$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-13
    eval wget $chrome_launcher -O /home/$findUser/.config/xfce4/panel/launcher-13/16325911153.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Chrome$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-14
    eval wget $user_term_launcher -O /home/$findUser/.config/xfce4/panel/launcher-14/16325912214.desktop
    eval wget $root_term_launcher -O /home/$findUser/.config/xfce4/panel/launcher-14/16325914395.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Terminal$color_nocolor launchers (user + root)"

    eval wget $ip_widget -O /home/$findUser/.config/xfce4/panel/genmon-17.rc
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green genmon IP$color_nocolor widget"

    mkdir -p /home/$findUser/.local/panel-scripts
    eval wget $ip_script -O /home/$findUser/.local/panel-scripts/menu-ip.sh
    chmod +x /home/$findUser/.local/panel-scripts/menu-ip.sh
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green genmon IP$color_nocolor shell script"

    eval wget $net_widget -O /home/$findUser/.config/xfce4/panel/netload-21.rc
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green network monitor$color_nocolor widget"

    # backup xfce4-panel config
    panelFile="/home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    cp $panelFile /home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.bak

    eval wget $panel_conf -O $panelFile
    echo -e "\n  $greenplus xfce4 panel config : downloaded new configuration file"

    # replace whisker settings
    whiskerFile="/home/$findUser/.config/xfce4/panel/whiskermenu-7.rc"
    cp $whiskerFile /home/$findUser/.config/xfce4/panel/whiskermenu-7.bak

    eval wget $whisker_new -O $whiskerFile
    echo -e "\n  $greenplus whiskermenu : downloaded new configuration file"

    echo -e "\n  $blinkwarn Reboot required."
}

switch_to_lightdm() {
    # Switch from default SDDM to LightDM

    pacman -Q lightdm > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        pacman -Sy lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm --needed
        echo -e "\n  $greenplus lightdm : installed"
    fi

    systemctl enable lightdm.service -f
    echo -e "\n  $greenstar lightdm : system configured for lightdm"

    gtk_greeter="$(cat <<-EOF
[greeter]
theme-name = Arc-Fire-Dark
icon-theme-name = HALODARK
background = /usr/share/backgrounds/arcolinux/time-abstract.jpg
user-background = false
default-user-image = /etc/skel/.config/arcolinux-logo/arcolinux.png
screensaver-timeout = 0
position = 25%,center 50%,center
EOF
)"
    echo "$gtk_greeter" > /etc/lightdm/lightdm-gtk-greeter.conf
    echo -e "\n  $greenstar lightdm-greeter : basic configuration written to$color_light_green /etc/lightdm/lightdm-gtk-greeter.conf$color_nocolor"

    echo -e "\n  $blinkwarn Reboot required."
}

xfce4_thunar_terminal() {
    # Set Alacritty or Kitty as default terminal in Thunar config.

    ucaFile="/home/$findUser/.config/Thunar/uca.xml"
    cp $ucaFile /home/$findUser/.config/Thunar/uca.bak

    #xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "alacritty -e %f" /home/bryan/.config/Thunar/uca.xml
    #eval $(xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "alacritty -e %f" $ucaFile)

    case $termPref in
        kitty)
            eval $(xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "kitty %f" $ucaFile)
            eval $(xmlstarlet edit -P -L --update '/actions/action[name = "Open Terminal Here"]/command' -v "kitty" $ucaFile)
            echo -e "\n  $greenstar thunar : Terminal preferences set to use$color_light_green KITTY$color_nocolor"
            ;;
        alacritty)
            eval $(xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "alacritty -e %f" $ucaFile)
            eval $(xmlstarlet edit -P -L --update '/actions/action[name = "Open Terminal Here"]/command' -v "alacritty" $ucaFile)
            echo -e "\n  $greenstar thunar : Terminal preferences set to use$color_light_green ALACRITTY$color_nocolor"
            ;;
        *)
            echo -e "\n  $yellowstar thunar : Unsupported terminal specified, defaults unchanged"
            ;;
    esac
}

xfce4_helpers_terminal() {
    # Set Alacritty or Kitty as default terminal in .local/share/xfce4/helpers .desktop file

    termEmuDesktop="/home/$findUser/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"
    cp $termEmuDesktop /home/$findUser/.local/share/xfce4/helpers/custom-TerminalEmulator.bak

    #eval $(awk -i inplace '/^X-XFCE-CommandsWithParameter=/{$0="X-XFCE-CommandsWithParameter=alacritty \"%s\""}1' $termEmuDesktop)
    #eval $(awk -i inplace '/^Icon=/{$0="Icon=alacritty"}1' $termEmuDesktop)
    #eval $(awk -i inplace '/^Name=/{$0="Name=alacritty"}1' $termEmuDesktop)
    #eval $(awk -i inplace '/^X-XFCE-Commands=/{$0="X-XFCE-Commands=alacritty"}1' $termEmuDesktop)

    case $termPref in
        kitty)
            eval $(awk -i inplace '/^X-XFCE-CommandsWithParameter=/{$0="X-XFCE-CommandsWithParameter=kitty \"%s\""}1' $termEmuDesktop)
            eval $(awk -i inplace '/^Icon=/{$0="Icon=kitty"}1' $termEmuDesktop)
            eval $(awk -i inplace '/^Name=/{$0="Name=kitty"}1' $termEmuDesktop)
            eval $(awk -i inplace '/^X-XFCE-Commands=/{$0="X-XFCE-Commands=kitty"}1' $termEmuDesktop)
            echo -e "\n  $greenstar default apps : default terminal emulator set to$color_light_green KITTY$color_nocolor"
            ;;
        alacritty)
            eval $(awk -i inplace '/^X-XFCE-CommandsWithParameter=/{$0="X-XFCE-CommandsWithParameter=alacritty \"%s\""}1' $termEmuDesktop)
            eval $(awk -i inplace '/^Icon=/{$0="Icon=alacritty"}1' $termEmuDesktop)
            eval $(awk -i inplace '/^Name=/{$0="Name=alacritty"}1' $termEmuDesktop)
            eval $(awk -i inplace '/^X-XFCE-Commands=/{$0="X-XFCE-Commands=alacritty"}1' $termEmuDesktop)
            echo -e "\n  $greenstar default apps : default terminal emulator set to$color_light_green ALACRITTY$color_nocolor"
            ;;
        *)
            echo -e "\n  $yellowstar default apps : Unsupported terminal specified, defaults unchanged"
            ;;
    esac
}

delete_variety_app() {
    # Delete the pre-installed "Variety" wallpaper app

    pacman -R variety --noconfirm
    pacman -R arcolinux-variety-git --noconfirm
    echo -e "\n  $greenminus variety app : removed pre-installed 'variety' wallpaper application"
}

revert_network_naming() {
    # See: https://wiki.archlinux.org/title/Network_configuration#Revert_to_traditional_interface_names
    eval $(ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules)
    echo -e "\n  $greenstar network : reverted to traditional interface naming"
}

fetch_kitty_config() {
    kittyFile="/home/$findUser/.config/kitty/kitty.conf"
    if [[ -f "$kittyFile" ]]; then
        cp $kittyFile /home/$findUser/.config/kitty/kitty.bak
    else
        mkdir -p /home/$findUser/.config/kitty
    fi

    eval wget $kitty_conf -O $kittyFile
    echo -e "\n  $greenplus kitty : downloaded new configuration file"

}

switch_to_zsh() {
    # Switch from BASH to ZSH

    eval $(chsh $findUser -s /bin/zsh)
    echo -e "\n  $greenstar terminal : changed from bash to$color_light_green zsh$color_nocolor"
    echo -e "\n  $blinkwarn Reboot required."
}

install_p10k_fonts() {
    # Install fonts necessary for Powerlevel10k theme

    echo -e "\n  $yellowstar fonts : now attempting font install as user$color_other_yellow $findUser $color_nocolor"

    mesloNerdFont="paru -Sy ttf-meslo-nerd-font-powerlevel10k --needed"
    awesomeTerminalFont="paru -Sy awesome-terminal-fonts --needed"
    powerlineGitFont="paru -Sy powerline-fonts-git --needed"
    jetbrainsNerdFont="paru -Sy nerd-fonts-jetbrains-mono --needed"

    sudo -u $findUser $mesloNerdFont
    sudo -u $findUser $awesomeTerminalFont
    sudo -u $findUser $powerlineGitFont
    sudo -u $findUser $jetbrainsNerdFont
}


# execution
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$blinkexclaim ERROR : This script must be run as root. Run again with 'sudo'."
    exit 1
fi

clear
echo -e "\n$blinkwarn NOTICE : This script is not intended for UNATTENDED execution."
echo -e "If you have not updated ALL packages, cancel this script with CTRL+C and do so first. THEN come back and run this script."
echo -e "\nThis script is the first of multiple. After completion of this script, reboot the system and proceed with additional scripts."
#read -n 1 -r -s -p "       Press any key to continue..."
read -p "Press [ENTER] to continue..."
echo " "

vm_install
required_apps
disable_power_mgmt
switch_to_lightdm
xfce4_thunar_terminal
xfce4_helpers_terminal
delete_variety_app
revert_network_naming
fetch_kitty_config
switch_to_zsh
xfce4_panel_mod
install_p10k_fonts
##preferred_apps

echo -e "\n  $blinkwarn COMPLETE : Reboot required. Proceed with any additional scripts after successful restart."
