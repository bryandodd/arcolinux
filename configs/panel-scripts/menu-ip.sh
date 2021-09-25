#!/bin/bash

# See: https://jonasjacek.github.io/colors/
#      https://shinmera.github.io/pango-markup/
#      https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start

wlanIp=$((ifconfig wlan0 | grep -w inet | awk '{print $2}') 2> /dev/null)
lanIp=$((ifconfig eth0 | grep -w inet | awk '{print $2}') 2> /dev/null)
vpnIp=$((ifconfig tun0 | grep -w inet | awk '{print $2}') 2> /dev/null)

ipList=$(if ! [ -z ${wlanIp} ]; then echo "<i>wlan0:</i> <span foreground='green3'><b>$wlanIp</b></span> | "; fi)
ipList+=$(if ! [ -z ${lanIp} ]; then echo "<i>eth0:</i> <span foreground='green3'><b>$lanIp</b></span> | "; fi)
ipList+=$(if ! [ -z ${vpnIp} ]; then echo "<i>tun0:</i> <span foreground='yellow'><b>$vpnIp</b></span> | "; fi)
output="<txt>$ipList"
output="${output%| }</txt>"

if [ "$output" == "" ]; then output="No Interface Ip!"; fi

echo "$output"