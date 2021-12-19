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
    revision="0.2.2"

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

    sddm_background="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/sddm/darkkali.jpg"
    sddm_theme_config="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/sddm/theme.conf"
    sddm_config="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/sddm/sddm.conf"


findUser=$(logname)
userId=$(id -u $findUser)
userGroup=$(id -g -n $findUser)
userGroupId=$(id -g $findUser)

sudoUser=$(whoami)
sudoId=$(id -u $sudoUser)
sudoGroup=$(id -g -n $sudoUser)
sudoGroupId=$(id -g $sudoUser)

# terminal preference (kitty -or- alacritty)
termPref="kitty"

fix_local_permissions() {
    chown -R $findUser:$userGroup /home/$findUser/.config
    echo -e "\n  $cyanstar permissions : set$color_other_yellow $findUser $color_nocolor as owner of$color_other_yellow ~/.config $color_nocolor"
}

fix_config_permissions() {
    chown -R $findUser:$userGroup /home/$findUser/.config
    echo -e "\n  $cyanstar permissions : set$color_other_yellow $findUser $color_nocolor as owner of$color_other_yellow ~/.config $color_nocolor"
}

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

disable_power_mgmt() {
    # Set screen blanking / sleep to 0 and then disable power management entirely.
    # Values are zeroed out in the event that power management gets turned back on accidentally.

    # settings for USER

    userPowerConf="/home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml"
    cp $userPowerConf /home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.bak

    xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-sleep']/@value" --value "0" $userPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-off']/@value" --value "0" $userPowerConf
    xmlstarlet edit -P -L --update "//property[@name='blank-on-ac']/@value" --value "0" $userPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-sleep']/@value" --value "0" $userPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-off']/@value" --value "0" $userPowerConf
    xmlstarlet edit -P -L --update "//property[@name='blank-on-battery']/@value" --value "0" $userPowerConf
    userPowerDisabled=$(xmlstarlet sel -t -v "count(//property[@name='dpms-enabled'])" $userPowerConf)
    if [[ $userPowerDisabled -ne 1 ]]; then
        xmlstarlet edit -P -L -s "/channel[@name='xfce4-power-manager']/property[@name='xfce4-power-manager']" -t elem -n "propertyTemp" -v "" -i "//propertyTemp" -t attr -n "name" -v "dpms-enabled" -i "//propertyTemp" -t attr -n "type" -v "bool" -i "//propertyTemp" -t attr -n "value" -v "false" -r "//propertyTemp" -v "property" $userPowerConf
    fi
    echo -e "\n  $greenstar power management : USER configured for zero timeout and disabled"
    fix_config_permissions

    # settings for ROOT
    rootPowerConf="/root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml"
    cp $rootPowerConf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.bak

    xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-sleep']/@value" --value "0" $rootPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-ac-off']/@value" --value "0" $rootPowerConf
    xmlstarlet edit -P -L --update "//property[@name='blank-on-ac']/@value" --value "0" $rootPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-sleep']/@value" --value "0" $rootPowerConf
    xmlstarlet edit -P -L --update "//property[@name='dpms-on-battery-off']/@value" --value "0" $rootPowerConf
    xmlstarlet edit -P -L --update "//property[@name='blank-on-battery']/@value" --value "0" $rootPowerConf
    rootPowerDisabled=$(xmlstarlet sel -t -v "count(//property[@name='dpms-enabled'])" $rootPowerConf)
    if [[ $rootPowerDisabled -ne 1 ]]; then
        xmlstarlet edit -P -L -s "/channel[@name='xfce4-power-manager']/property[@name='xfce4-power-manager']" -t elem -n "propertyTemp" -v "" -i "//propertyTemp" -t attr -n "name" -v "dpms-enabled" -i "//propertyTemp" -t attr -n "type" -v "bool" -i "//propertyTemp" -t attr -n "value" -v "false" -r "//propertyTemp" -v "property" $rootPowerConf
    fi
    echo -e "\n  $greenstar power management : ROOT configured for zero timeout and disabled"
}

xfce4_panel_mod() {
    # Set preferences for the xfce4 main panel

    # download panel configs
    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-1
    eval wget -q $sublime_launcher -O /home/$findUser/.config/xfce4/panel/launcher-1/16325907731.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Sublime$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-12
    eval wget -q $firefox_launcher -O /home/$findUser/.config/xfce4/panel/launcher-12/16325911012.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Firefox$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-13
    eval wget -q $chrome_launcher -O /home/$findUser/.config/xfce4/panel/launcher-13/16325911153.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Chrome$color_nocolor launcher"

    mkdir -p /home/$findUser/.config/xfce4/panel/launcher-14
    eval wget -q $user_term_launcher -O /home/$findUser/.config/xfce4/panel/launcher-14/16325912214.desktop
    eval wget -q $root_term_launcher -O /home/$findUser/.config/xfce4/panel/launcher-14/16325914395.desktop
    echo -e "\n  $greenplus xfce4 launcher : downloaded$color_light_green Terminal$color_nocolor launchers (user + root)"

    genmonFile="/home/$findUser/.config/xfce4/panel/genmon-17.rc"
    eval wget -q $ip_widget -O $genmonFile
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green genmon IP$color_nocolor widget"
    # fix menu-ip.sh path - set to match current user
    fixMenuIPPath="/home/$findUser/.local/panel-scripts/menu-ip.sh"
    sed -i "1s|.*|Command=$fixMenuIPPath|" $genmonFile
    echo -e "\n  $greenstar xfce4 panel : updated script path for$color_light_green IP$color_nocolor widget to match current user"

    mkdir -p /home/$findUser/.local/panel-scripts
    eval wget -q $ip_script -O /home/$findUser/.local/panel-scripts/menu-ip.sh
    chmod +x /home/$findUser/.local/panel-scripts/menu-ip.sh
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green genmon IP$color_nocolor shell script"

    eval wget -q $net_widget -O /home/$findUser/.config/xfce4/panel/netload-21.rc
    echo -e "\n  $greenplus xfce4 panel : downloaded$color_light_green network monitor$color_nocolor widget"

    # backup xfce4-panel config
    panelFile="/home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    cp $panelFile /home/$findUser/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.bak

    eval wget -q $panel_conf -O $panelFile
    echo -e "\n  $greenplus xfce4 panel config : downloaded new configuration file"
    # fix base-directory path - set to match current user
    xmlstarlet edit -P -L --update "//property[@name='base-directory']/@value" --value "/home/$findUser" $panelFile
    echo -e "\n  $greenstar xfce4 panel config : updated base-directory to match current user"

    # replace whisker settings
    whiskerFile="/home/$findUser/.config/xfce4/panel/whiskermenu-7.rc"
    cp $whiskerFile /home/$findUser/.config/xfce4/panel/whiskermenu-7.bak

    eval wget -q $whisker_new -O $whiskerFile
    echo -e "\n  $greenplus whiskermenu : downloaded new configuration file"

    fix_local_permissions
    fix_config_permissions
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

configure_sddm() {
    # Configure SDDM

    paru -Q sddm-config-editor-git > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy arcolinux_repo_3party/sddm-config-editor-git --needed --noconfirm
        echo -e "\n  $greenplus sddm config editor : installed \n"
    fi

    paru -Q arcolinux-sddm-sugar-candy-git > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy arcolinux_repo/arcolinux-sddm-sugar-candy-git --needed --noconfirm
        echo -e "\n  $greenplus sddm : sugar-candy theme installed \n"
    fi

    if [ -d /usr/share/sddm/themes/arcolinux-sugar-candy/ ]; then
        sddmbg="/usr/share/sddm/themes/arcolinux-sugar-candy/Backgrounds/darkkali.jpg"
        eval wget -q $sddm_background -O $sddmbg
        echo -e "\n  $greenplus sddm-config : fetched background image \n"

        themeConfig="/usr/share/sddm/themes/arcolinux-sugar-candy/theme.conf"
        cp $themeConfig /usr/share/sddm/themes/arcolinux-sugar-candy/theme.orig-bak
        eval wget -q $sddm_theme_config -O $themeConfig
        echo -e "\n  $greenplus sddm-config : fetched theme config \n"

        sddmConfig="/etc/sddm.conf"
        cp $sddmConfig /etc/sddm.orig-bak
        eval wget -q $sddm_config -O $sddmConfig
        echo -e "\n  $greenplus sddm : fetched sddm config \n"
    else
        echo -e "$yellowstar SDDM theme directory not found. Skipping SDDM configuration."
    fi
}

xfce4_thunar_terminal() {
    # Set Alacritty or Kitty as default terminal in Thunar config.

    ucaFile="/home/$findUser/.config/Thunar/uca.xml"
    cp $ucaFile /home/$findUser/.config/Thunar/uca.bak

    case $termPref in
        kitty)
            xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "kitty %f" $ucaFile
            xmlstarlet edit -P -L --update '/actions/action[name = "Open Terminal Here"]/command' -v "kitty" $ucaFile
            echo -e "\n  $greenstar thunar : Terminal preferences set to use$color_light_green KITTY$color_nocolor"
            ;;
        alacritty)
            xmlstarlet edit -P -L --update '/actions/action[name = "Run"]/command' -v "alacritty -e %f" $ucaFile
            xmlstarlet edit -P -L --update '/actions/action[name = "Open Terminal Here"]/command' -v "alacritty" $ucaFile
            echo -e "\n  $greenstar thunar : Terminal preferences set to use$color_light_green ALACRITTY$color_nocolor"
            ;;
        *)
            echo -e "\n  $yellowstar thunar : Unsupported terminal specified, defaults unchanged"
            ;;
    esac
    fix_config_permissions
}

xfce4_helpers_terminal() {
    # Set Alacritty or Kitty as default terminal in .local/share/xfce4/helpers .desktop file

    termEmuDesktop="/home/$findUser/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"
    cp $termEmuDesktop /home/$findUser/.local/share/xfce4/helpers/custom-TerminalEmulator.bak

    case $termPref in
        kitty)
            awk -i inplace '/^X-XFCE-CommandsWithParameter=/{$0="X-XFCE-CommandsWithParameter=kitty \"%s\""}1' $termEmuDesktop
            awk -i inplace '/^Icon=/{$0="Icon=kitty"}1' $termEmuDesktop
            awk -i inplace '/^Name=/{$0="Name=kitty"}1' $termEmuDesktop
            awk -i inplace '/^X-XFCE-Commands=/{$0="X-XFCE-Commands=kitty"}1' $termEmuDesktop
            echo -e "\n  $greenstar default apps : default terminal emulator set to$color_light_green KITTY$color_nocolor"
            ;;
        alacritty)
            awk -i inplace '/^X-XFCE-CommandsWithParameter=/{$0="X-XFCE-CommandsWithParameter=alacritty \"%s\""}1' $termEmuDesktop
            awk -i inplace '/^Icon=/{$0="Icon=alacritty"}1' $termEmuDesktop
            awk -i inplace '/^Name=/{$0="Name=alacritty"}1' $termEmuDesktop
            awk -i inplace '/^X-XFCE-Commands=/{$0="X-XFCE-Commands=alacritty"}1' $termEmuDesktop
            echo -e "\n  $greenstar default apps : default terminal emulator set to$color_light_green ALACRITTY$color_nocolor"
            ;;
        *)
            echo -e "\n  $yellowstar default apps : Unsupported terminal specified, defaults unchanged"
            ;;
    esac
    fix_local_permissions
}

delete_variety_app() {
    # Delete the pre-installed "Variety" wallpaper app

    pacman -R variety --noconfirm
    pacman -R arcolinux-variety-git --noconfirm
    echo -e "\n  $greenminus variety app : removed pre-installed 'variety' wallpaper application"
}

revert_network_naming() {
    # See: https://wiki.archlinux.org/title/Network_configuration#Revert_to_traditional_interface_names
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
    echo -e "\n  $greenstar network : reverted to traditional interface naming"
}

fetch_kitty_config() {
    kittyFile="/home/$findUser/.config/kitty/kitty.conf"
    if [[ -f "$kittyFile" ]]; then
        cp $kittyFile /home/$findUser/.config/kitty/kitty.bak
    else
        mkdir -p /home/$findUser/.config/kitty
    fi

    eval wget -q $kitty_conf -O $kittyFile
    echo -e "\n  $greenplus kitty : downloaded new configuration file"
    fix_config_permissions
}

switch_to_zsh() {
    # Switch from BASH to ZSH

    chsh $findUser -s /bin/zsh
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
read -p "Press [ENTER] to continue..."
echo " "

#vm_install
required_apps
disable_power_mgmt

#switch_to_lightdm
configure_sddm

xfce4_thunar_terminal
xfce4_helpers_terminal
delete_variety_app
revert_network_naming
fetch_kitty_config
switch_to_zsh
xfce4_panel_mod
install_p10k_fonts

echo -e "\n  $blinkwarn COMPLETE : Reboot required. Proceed with any additional scripts after successful restart."
