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
    revision="0.2.1"

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
    smbOrigConf="https://git.samba.org/samba.git/?p=samba.git;a=blob_plain;f=examples/smb.conf.default;hb=HEAD"
    smbCustConf="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/smb/smb.conf"
    smbAddShare="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/smb/addshare.py"
    smbSetOpt="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/smb/setoption.py"
    smbPanic="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/smb/panic-action"
    smbUpdate="https://raw.githubusercontent.com/bryandodd/arcolinux/main/configs/smb/update-apparmor-samba-profile"
    pyLeetGen="https://raw.githubusercontent.com/bryandodd/arcolinux/main/python/leetgen.py"

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
        echo -e "\n  $greenplus golang : installed \n"
    fi

    # Create local user 'go' path
    mkdir -p /home/$findUser/go/{bin,src}; chown -R $findUser:$findUser /home/$findUser/go
    echo -e "\n  $greenplus golang : created path /home/$finduser/go/bin"
    echo -e "\n  $greenplus golang : created path /home/$finduser/go/src  \n"

    # Register local user 'go' directories with path (update .zshrc)
    zshFile="/home/$findUser/.zshrc"
    sed -i '/^# reporting.*/i export GOPATH=\$HOME/go\nexport PATH=\$PATH:\$GOPATH/bin\n' $zshFile
    echo -e "\n  $greenstar zshrc : PATH updated - now includes$color_other_yellow \$HOME/go/bin $color_nocolor \n"
    chown $findUser:$userGroup $zshFile
}

install_samba() {
    # Install smb support
    paru -Q samba > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy extra/samba --needed --noconfirm
        echo -e "\n  $greenplus samba : installed \n"
    fi

    origConf="/etc/samba/smb.conf.original"
    if test -f "$origConf"; then
        echo -e "$yellowstar Original smb.conf file found. Skipping download."
    else
        eval wget -q $smbOrigConf -O $origConf
        echo -e "$greenplus Downloaded smb.conf.original to $origConf"
    fi

    custConf="/etc/samba/smb.conf"
    if test -f "$custConf"; then
        echo -e "$yellowstar Custom smb.conf file found. Skipping download."
    else
        eval wget -q $smbCustConf -O $custConf
        echo -e "$greenplus Downloaded smb.conf to $custConf"
    fi

    addpy="/usr/share/samba/addshare.py"
    if test -f "$addpy"; then
        echo -e "$yellowstar addshare.py found. Skipping download."
    else
        eval wget -q $smbAddShare -O $addpy
        echo -e "$greenplus Downloaded addshare.py to $addpy"
    fi

    setpy="/usr/share/samba/setoption.py"
    if test -f "$setpy"; then
        echo -e "$yellowstar setoption.py found. Skipping download."
    else
        eval wget -q $smbSetOpt -O $setpy
        echo -e "$greenplus Downloaded setoption.py to $setpy"
    fi

    panicAction="/usr/share/samba/panic-action"
    if test -f "$panicAction"; then
        echo -e "$yellowstar panic-action found. Skipping download."
    else
        eval wget -q $smbPanic -O $panicAction
        echo -e "$greenplus Downloaded panic-action to $panicAction"
    fi

    smbAppArmor="/usr/share/samba/update-apparmor-samba-profile"
    if test -f "$smbAppArmor"; then
        echo -e "$yellowstar update-apparmor-samba-profile found. Skipping download."
    else
        eval wget -q $smbUpdate -O $smbAppArmor
        echo -e "$greenplus Downloaded update-apparmor-samba-profile to $smbAppArmor"
    fi

    paru -Q thunar-shares-plugin > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy arcolinux_repo_3party/thunar-shares-plugin --needed --noconfirm
        echo -e "\n  $greenplus samba : thunar share plugin \n"
    fi
}

notes_samba() {
    # Follow-up notes regarding use of Samba support:
    echo -e "\n$cyanstar NOTES :: SAMBA"
    echo -e "\n   Use$color_other_yellow sudo systemctl enable smb.service$color_nocolor to activate at startup."
    echo -e "   Use$color_other_yellow sudo systemctl enable nmb.service$color_nocolor to activate at startup."
    echo -e "\n   Use$color_other_yellow sudo systemctl start smb.service$color_nocolor to start smb service."
    echo -e "   Use$color_other_yellow sudo systemctl start nmb.service$color_nocolor to start nmb service.\n"
}

install_impacket() {
    # Install Impacket version 0.9.19 (line 912)
    tmpDir="/home/$findUser/tmp-installer"
    [ -d $tmpDir ] || mkdir $tmpDir

    eval wget -q https://github.com/SecureAuthCorp/impacket/releases/download/impacket_0_9_19/impacket-0.9.19.tar.gz -O $tmpDir/impacket-0.9.19.tar.gz
    eval tar xfz $tmpDir/impacket-0.9.19.tar.gz -C /opt
    chown -R $sudoUser:$sudoGroup /opt/impacket-0.9.19
    chmod -R 755 /opt/impacket-0.9.19

    cd /opt/impacket-0.9.19
    eval pip3 install lsassy
    echo -e "\n  $greenplus pip3 : installed$color_other_yellow lsassy $color_nocolor \n"
    eval pip2 install flask
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow flask $color_nocolor \n"
    eval pip2 install pyasn1
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow pyasn1 $color_nocolor \n"
    eval pip2 install pycryptodomex
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow pycryptodomex $color_nocolor \n"
    eval pip2 install pyOpenSSL
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow pyOpenSSL $color_nocolor \n"
    eval pip2 install ldap3
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow ldap3 $color_nocolor \n"
    eval pip2 install ldapdomaindump
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow ldapdomaindump $color_nocolor \n"
    eval pip2 install wheel
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow wheel $color_nocolor \n"
    eval pip2 install .
    echo -e "\n  $greenplus pip2 : installed$color_other_yellow impacket $color_nocolor \n"
    rm -f $tmpDir/impacket-0.9.19.tar.gz

    #paru -Q impacket > /dev/null 2>&1
    #if [[ $? -ne 0 ]]; then
    #    paru -Sy community/impacket --needed --noconfirm
    #fi

    echo -e "\n  $greenplus impacket : impacket and supporting packages installed \n"
}

install_nmap() {
    # Install nmap and script-fix
    paru -Q nmap > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy extra/nmap --needed --noconfirm
        echo -e "\n  $greenplus nmap : installed \n"
    fi

    nmapScripts="/usr/share/nmap/scripts"
    mv $nmapScripts/http-shellshock.nse $nmapScripts/http-shellshock-orig.nse
    eval wget -q https://raw.githubusercontent.com/onomastus/pentest-tools/master/fixed-http-shellshock.nse -O $nmapScripts/http-shellshock.nse
    echo -e "\n  $greenstar nmap : replaced http-shellshock scripts (original was suffixed with '-orig') \n"
}

install_java() {
    # Install OpenJDK 11 (https://archlinux.org/packages/extra/x86_64/jdk11-openjdk/)
    paru -Q jdk11-openjdk > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy extra/jdk11-openjdk --needed --noconfirm
        echo -e "\n  $greenplus java : installed openjdk v11 \n"
    fi
}

install_burpsuite() {
    # Install Burpsuite CE
    paru -Q burpsuite > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/burpsuite --needed --noconfirm
        echo -e "\n  $greenplus burpsuite : installed \n"
    fi
}

notes_burpsuite() {
    # Follow-up notes regarding use of Burpsuite:
    echo -e "\n$cyanstar NOTES :: BURPSUITE"
    echo -e "\n   Consider using a Firefox addon called$color_other_yellow FoxyProxy Standard$color_nocolor."
    echo -e "   This tool provides a very simple and easy-to-use interface for quickly enabling/disabling proxy traffic while using Burpsuite."
    echo -e "\n   https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/?utm_source=addons.mozilla.org&utm_medium=referral&utm_content=search\n"
}

install_metasploit() {
    # Install Metasploit Framework (https://archlinux.org/packages/community/x86_64/metasploit/)
    # see also: https://www.metasploit.com/
    paru -Q metasploit > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy community/metasploit --needed --noconfirm
        echo -e "\n  $greenplus metasploit : installed \n"
    fi
}

install_custom_python() {
    pyDir="/opt/python-scripts"
    [ -d $pyDir ] || mkdir $pyDir

    leetgen="/opt/python-scripts/leetgen.py"
    if test -f "$leetgen"; then
        echo -e "$yellowstar leetgen.py found. Skipping download."
    else
        eval wget -q $pyLeetGen -O $leetgen
        echo -e "$greenplus Downloaded leetgen.py to $leetgen"

        # symlink
        ln -s /opt/python-scripts/leetgen.py /usr/local/bin/leetgen.py
        echo -e "\n $greenstar leetgen.py : symbolic link created - /usr/local/bin/leetgen.py \n"
    fi
}

install_amass() {
    # Install OWASP Amass v3 (https://github.com/OWASP/Amass)
    amassVer="v3.15.1"
    amassPath="https://github.com/OWASP/Amass/releases/download/$amassVer/amass_linux_amd64.zip"

    if [ -d /opt/amass_linux_amd64 ]; then
        echo -e "$yellowstar amass already present. Skipping install."
    else
        tmpDir="/home/$findUser/tmp-installer"
        [ -d $tmpDir ] || mkdir $tmpDir

        eval wget -q $amassPath -O $tmpDir/amass_linux_amd64.zip
        eval unzip $tmpDir/amass_linux_amd64.zip -d /opt
        rm -f $tmpDir/amass_linux_amd64.zip
        echo -e "\n $greenplus amass : installed to /opt"

        # symlink
        ln -s /opt/amass_linux_amd64/amass /usr/local/bin/amass
        echo -e "\n $greenstar amass : symbolic link created - /usr/local/bin/amass \n"
    fi
}

install_whatweb() {
    # Install WhatWeb (https://github.com/urbanadventurer/WhatWeb)
    paru -Q whatweb > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/whatweb --needed --noconfirm
        echo -e "\n  $greenplus whatweb : installed \n"
    fi
}

install_nikto() {
    # Install Nikto (https://github.com/sullo/nikto)
    # see also: https://cirt.net/Nikto2
    paru -Q nikto > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy community/nikto --needed --noconfirm
        echo -e "\n  $greenplus nikto : installed \n"
    fi
}

install_dirbuster() {
    # Install DirBuster
    paru -Q dirbuster > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/dirbuster --needed --noconfirm
        echo -e "\n  $greenplus dirbuster : installed \n"
    fi
}

install_gobuster() {
    # Install GoBuster (https://github.com/OJ/gobuster)
    paru -Q gobuster > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/gobuster --needed --noconfirm
        echo -e "\n  $greenplus gobuster : installed \n"
    fi
}

install_searchsploit() {
    # Install ExploitDB Archive (https://www.exploit-db.com/searchsploit)
    paru -Q exploitdb > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy community/exploitdb --needed --noconfirm
        echo -e "\n  $greenplus searchsploit : installed \n"
    fi
}

install_nessus() {
    # Install Nessus Scanner (https://www.tenable.com/products/nessus)
    paru -Q nessus > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/nessus --needed --noconfirm
        echo -e "\n  $greenplus nessus : installed \n"
    fi
}

notes_nessus() {
    # Follow-up notes regarding Nessus Scanner:
    echo -e "\n$cyanstar NOTES :: NESSUS"
    echo -e "\n   Use$color_other_yellow systemctl start nessusd$color_nocolor to launch the service."
    echo -e "   Then go to$color_other_yellow https://localhost:8834$color_nocolor (or substitute hostname) in your browser to complete the setup and configure the scanner."
    echo -e "\n   This software requires a license. You will be prompted during web setup to complete the registration for a free 'essentials' license key.\n"
}

download_powersploit() {
    # Download the PowerSploit PowerShell library
    powerSploitLib="/opt/powersploit"

    if [ -d $powerSploitLib ]; then
        echo -e "$yellowstar PowerSploit directory already exists. Skipping download."
    else
        mkdir $powerSploitLib
        git clone https://github.com/PowerShellMafia/PowerSploit.git $powerSploitLib
        # repo is archived - no reason to leave git repo config in place
        rm -rf /opt/powersploit/.git
        rm -rf /opt/powersploit/.gitignore
        echo -e "\n  $greenplus powersploit : library downloaded to /opt/powersploit \n"
    fi
}

install_hydra() {
    # Install Hydra (https://github.com/vanhauser-thc/thc-hydra)
    paru -Q hydra > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        paru -Sy community/hydra --needed --noconfirm
        echo -e "\n  $greenplus hydra : installed \n"
    fi
}

install_responder() {
    # Install Responder (https://github.com/lgandx/Responder)
    paru -Q responder > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        sudo -u $findUser paru -Sy aur/responder --needed --noconfirm
        echo -e "\n  $greenplus responder : installed \n"
    fi
}

notes_responder() {
    # Follow-up notes regarding Responder:
    echo -e "\n$cyanstar NOTES :: RESPONDER"
    echo -e "\n   See$color_other_yellow /usr/share/responder/Responder.conf$color_nocolor for configuration changes. \n"
}

install_mitm6() {
    # Install mitm6 (https://github.com/dirkjanm/mitm6)
    # IPv6 man-in-the-middle attack
    mitmDir="/opt/mitm6"
    
    if [ -d $mitmDir ]; then
        echo -e "$yellowstar mitm6 directory already exists. Skipping install."
    else
        mkdir $mitmDir
        git clone https://github.com/dirkjanm/mitm6.git $mitmDir
        echo -e "\n  $greenplus mitm6 : download complete \n"

        # install from source
        cd $mitmDir
        eval pip2 install -r requirements.txt
        echo -e "\n  $greenplus pip2 : installed$color_other_yellow mitm6 requirements $color_nocolor \n"
        eval python2 setup.py install
        echo -e "\n  $greenplus python2 : installed$color_other_yellow mitm6 $color_nocolor \n"
        eval pip2 install service_identity
        echo -e "\n  $greenplus pip2 : installed$color_other_yellow mitm6 post-requirement :: service_identity $color_nocolor \n"
    fi
}


# execution
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$blinkexclaim ERROR : This script must be run as root. Run again with 'sudo'."
    exit 1
fi

clear
echo -e "\n$blinkwarn NOTICE : This script is not intended for UNATTENDED execution."
echo -e "If you have not updated ALL packages, cancel this script with CTRL+C and do so first. THEN come back and run this script."
echo -e "\nThis script is the THIRD of multiple and depends on execution of both arcomize-1.sh AND arcomize-2.sh previously. After completion of this script, reboot the system and proceed with additional scripts."
echo -e "\nSpecifically, this script installs an assortment of network analysis and penetration testing tools."
read -p "Press [ENTER] to continue..."
echo " "

install_golang
install_samba
install_impacket
install_nmap
install_java
install_burpsuite
install_metasploit
install_custom_python
install_amass
install_whatweb
install_nikto
install_dirbuster
install_gobuster
install_searchsploit
install_nessus
download_powersploit
install_hydra
install_responder
install_mitm6

notes_samba
notes_burpsuite
notes_nessus
notes_responder

echo -e "\n  $blinkwarn COMPLETE : Reboot recommended. Proceed with any additional scripts after successful restart."
