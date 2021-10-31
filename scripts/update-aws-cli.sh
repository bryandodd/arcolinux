#!/bin/bash
#
#set -e
# update-aws-cli.sh  Author: Bryan Dodd
# git clone 
# Usage: sudo ./update-aws-cli.sh
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

# static files
    aws_cli_v2="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

findUser=$(logname)

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$blinkexclaim ERROR : This script must be run as root. Run again with 'sudo'."
    exit 1
fi

# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
[ -d /home/$findUser/tmp-installer ] || mkdir /home/$findUser/tmp-installer
echo -e "\n  $greenstar downloading AWS CLI v2 from $aws_cli_v2"
curl -s $aws_cli_v2 -o /home/$findUser/tmp-installer/awscliv2.zip
echo -e "\n  $greenstar unpacking AWS CLI v2"
unzip -qq /home/$findUser/tmp-installer/awscliv2.zip -d /home/$findUser/tmp-installer

awsSymLink=$(which aws)
if [[ $? -ne 0 ]]; then
    echo -e "\n  $yellowstar AWS CLI : previous install not detected"
    # fresh install
    
    /home/$findUser/tmp-installer/aws/install
    echo -e "\n  $greenplus AWS CLI : installed"
else
    awsSymTarget=$(readlink -f $awsSymLink)
    echo -e "\n  $bluestar AWS CLI : previous install found : $awsSymLink -->$color_other_yellow $awsSymTarget $color_nocolor"
    # update existing install

    binDir=$(echo "$awsSymLink" | sed 's|\(.*\)/.*|\1|')
    installDir=$(echo "$awsSymTarget" | sed 's|\(.*\)/v2.*|\1|')

    /home/$findUser/tmp-installer/aws/install --bin-dir $binDir --install-dir $installDir --update
    echo -e "\n  $greenplus AWS CLI : update complete"
fi

echo -e "\n  $bluestar Testing AWS CLI installation ..."
aws --version

echo -e "\n  $bluestar Cleaning up ..."
rm -rf /home/$findUser/tmp-installer/aws
echo -e "\n  $greenminus deleted :$color_other_yellow ~/tmp-installer/aws$color_nocolor directory"
rm /home/$findUser/tmp-installer/awscliv2.zip
echo -e "\n  $greenminus deleted :$color_other_yellow awscliv2.zip $color_nocolor "
