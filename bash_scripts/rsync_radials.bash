#!/bin/bash
#-----------------------------------------------------------------------#
# RSYNC RADIALS 
# Script for sequential rsync-ing of radial data to the central site 
# computer by pulling from remote sites
#
# Designed to be called by a simple crontab line such as:
# 55 * * *  * /scripts/rsync_radials.bash
#
# Must have file permission set to executable, also requires passwordless
# ssh to be set up.
#
#
# Rsync switch explanations:
# -t, --times                 preserve times 
# -u, --update                update only (don't overwrite newer files)
# -v, --verbose
# -z, --compress              compress file data 
# -P     The  -P  option is equivalent to --partial --progress.
# -T  --temp-dir=DIR          create temporary files in directory DIR
#
#
# References:
# http://www.rowg.org/dm/rsync_and_scp/ 
# http://troy.jdmz.net/rsync/index.html
#
# Copyright (C) 2012 Brian Emery
#
# Originally  8 April 2008
#	Updates   3 Oct 2012


#-----------------------------------------------------------------------
function sync_files {
# SYNC FILES - sync files from remote sites
#  
# INPUT
# input a list of IP addresses to connect with (these become $1 variable)

# Define relevant paths and log files
rsync_log="$2"
local_dir="/data/radials/"
temp_dir="/data/radials/tmp/"
remote_files="/Volumes/CodarData/Codar/SeaSonde/Data/Radials/"

# Get the site code for use with local directory
site_code=$(ssh "$1" "head -1 /Codar/SeaSonde/Configs/RadialConfigs/Header.txt" | awk '{print $2}')


# RUN RSYNC JOB
rsync -tuzPrv  --timeout=30 --temp-dir="$temp_dir" "$1":"$remote_files" "$local_dir""$site_code"/ >> "$rsync_log"

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
 "128.111.242.149"   
 "iog.msi.ucsb.edu"  
 "fbk1.no-ip.net"
 "arg1.no-ip.net"
 "dcsr.no-ip.net"
 "dclr.no-ip.net"
 "estr.no-ip.net"
 "ragg.no-ip.net"
 "agl1.no-ip.net")


# DEFINE LOG FILE
rsync_log="/home/codar/web_data/logs/rsync_radials.log"


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









