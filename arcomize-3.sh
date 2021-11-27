#!/bin/bash
#
#set -e
# arcomize-3.sh  Author: Bryan Dodd
# git clone 
# Usage: sudo ./arcomize-3.sh
# command line arguments are valid, only catching 1 arguement
#
# Disclaimer: Author assumes no liability for any damage resulting from use, misuse, or any other crazy
#             idea somebody attempts using, incorporating, deconstructing, or anything else with this tool.

# revision
    revision="0.1.2"

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

findUser=$(logname)
userId=$(id -u $findUser)
userGroup=$(id -g -n $findUser)
userGroupId=$(id -g $findUser)

sudoUser=$(whoami)
sudoId=$(id -u $sudoUser)
sudoGroup=$(id -g -n $sudoUser)
sudoGroupId=$(id -g $sudoUser)


install_golang() {
    # Core compiler tools for the Go programming language
    paru -Q go > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy community/go --needed --noconfirm
        echo -e "\n  $greenplus golang : installed"
    fi

    # Create local user 'go' path
    mkdir -p /home/$findUser/go/{bin,src}; chown -R $findUser:$findUser /home/$findUser/go
    echo -e "\n  $greenplus golang : created path /home/$finduser/go/bin"
    echo -e "\n  $greenplus golang : created path /home/$finduser/go/src"

    # Register local user 'go' directories with path (update .zshrc)
    zshFile="/home/$findUser/.zshrc"
    sed -i '/^# reporting.*/i export GOPATH=\$HOME/go\nexport PATH=\$PATH:\$GOPATH/bin\n' $zshFile
    echo -e "\n  $greenstar zshrc : PATH updated - now includes$color_other_yellow \$HOME/go/bin $color_nocolor"
    chown $findUser:$userGroup $zshFile
}


# execution
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$blinkexclaim ERROR : This script must be run as root. Run again with 'sudo'."
    exit 1
fi

clear
echo -e "\n$blinkwarn NOTICE : This script is not intended for UNATTENDED execution."
echo -e "If you have not updated ALL packages, cancel this script with CTRL+C and do so first. THEN come back and run this script."
echo -e "\nThis script is the second of multiple and depends on execution of arcomize-1.sh previously. After completion of this script, reboot the system and proceed with additional scripts."
read -p "Press [ENTER] to continue..."
echo " "

install_golang

echo -e "\n  $blinkwarn COMPLETE : Reboot recommended. Proceed with any additional scripts after successful restart."
