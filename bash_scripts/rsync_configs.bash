#!/bin/bash
#-----------------------------------------------------------------------#
# RSYNC CONFIGS 
# Script for sequential rsync-ing of configs data to the central site 
# computer by pulling from remote sites
#
# Designed to be called by a simple crontab line such as:
# 55 * * *  * /scripts/rsync_radials.bash
#
# Must have file permission set to executable, also requires passwordless
# ssh to be set up.
#
# Copyright (C) 2013 Brian Emery
#
#	Updates 21 Apr 2013


#-----------------------------------------------------------------------
function sync_files {
# SYNC FILES - sync files from remote sites
#  
# INPUT
# input a list of IP addresses to connect with (these become $1 variable)

# Define relevant paths and log files
rsync_log="$2"
local_dir="/data/configs/"
temp_dir="/data/radials/tmp/"
remote_files="/Codar/SeaSonde/Configs/RadialConfigs/"

# Get the site code for use with local directory
# this is unreliable, so try other method
#site_code=$(ssh "$1" "head -1 /Codar/SeaSonde/Configs/RadialConfigs/Header.txt" | awk '{print $2}')
#
# use first 4 characters of IP alias
alias="$1"
site_code=${alias:0:4}


# RUN RSYNC JOB
rsync -tuzrv --delete --timeout=30 --temp-dir="$temp_dir" "$1":"$remote_files" "$local_dir""$site_code"/ >> "$rsync_log"

}
#-----------------------------------------------------------------------


# DEFINE SITE IP ALIASES

# nic1.dnsalias.com

 sites=(
 "nic1.dnsalias.com"
 "luis.marine.calpoly.edu"
 "sni1.dnsalias.com"
 "mgs1.dnsalias.com"
 "ptm1.dnsalias.com"
 "ssd1.dnsalias.com"
 "cop1.dnsalias.com"
 "rfg1.dnsalias.com"
 "ptc1.dnsalias.com"   
 "sci1.dnsalias.com"  
 "fbk1.no-ip.net"
 "arg1.no-ip.net"
 "dcsr.no-ip.net"
 "dclr.no-ip.net"
 "estr.no-ip.net"
 "ragg.no-ip.net"
 "agl1.no-ip.net")


# DEFINE LOG FILE
rsync_log="/home/codar/web_data/logs/rsync_configs.log"


# TIME STAMP LOG FILE

echo ----------------------------------------------------- >> "$rsync_log" 
echo START Running /home/codar/scripts/rsync_radials.bash  >> "$rsync_log"
date   >> "$rsync_log"


# RUN LOOP

for i in "${sites[@]}"
do
    echo ----------------------------------- >> "$rsync_log"
	echo $i	>> "$rsync_log"
	sync_files $i $rsync_log
done	
	


# put a time stamp at the end
date   >> "$rsync_log"
echo END  >> "$rsync_log"









