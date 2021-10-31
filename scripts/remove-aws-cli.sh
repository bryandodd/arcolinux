#!/bin/bash
#
#set -e
# remove-aws-cli.sh  Author: Bryan Dodd
# git clone 
# Usage: sudo ./remove-aws-cli.sh
#
# Disclaimer: Author assumes no liability for any damage resulting from use, misuse, or any other crazy
#             idea somebody attempts using, incorporating, deconstructing, or anything else with this tool.

# revision
    revision="0.1.0"

# colors
    color_nocolor='\e[0m'
    color_other_yellow='\e[1;93m'

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

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$blinkexclaim ERROR : This script must be run as root. Run again with 'sudo'."
    exit 1
fi

# Uninstall AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

awsSymLink=$(which aws)
if [[ $? -ne 0 ]]; then
    echo -e "\n  $yellowstar AWS CLI : previous install not detected"
    # nothing to uninstall
    
    echo -e "\n  $blinkwarn Nothing found to uninstall. Exiting..."
    exit 0
else
    completerSymLink=$(which aws_completer)
    awsSymTarget=$(readlink -f $awsSymLink)
    echo -e "\n  $bluestar AWS CLI : previous install found : $awsSymLink -->$color_other_yellow $awsSymTarget $color_nocolor"
    echo -e "\n  $bluestar AWS CLI : aws_completer symlink : $completerSymLink"

    # delete the symlinks
    rm $awsSymLink
    echo -e "\n  $greenminus AWS CLI : symlink$color_other_yellow $awsSymLink $color_nocolor deleted"
    rm $completerSymLink
    echo -e "\n  $greenminus AWS CLI : symlink$color_other_yellow $completerSymLink $color_nocolor deleted"

    # delete the install directory
    installDir=$(echo "$awsSymTarget" | sed 's|\(.*\)/v2.*|\1|')
    rm -rf $installDir
    echo -e "\n  $greenminus AWS CLI : install directory deleted"
fi