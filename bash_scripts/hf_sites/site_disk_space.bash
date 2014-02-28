#!/bin/bash
# SITE DISK SPACE
# 
# Designed to be run from stokes, write to a matlab readable txt file
# matlab does the parsing?
#
# Copyright (C) 2012 Brian Emery
#
#

#-----------------------------------------------------------------------
function do_work {
# DO WORK - run stuff on remote shells
# 
# probably should include a readme file also
# run from codar@stokes, /home/codar/Scripts/remote_rsync
#
# INPUT: the site IP address or network alias

# Do Stuff on Remote Site

# Get disk space
ssh "$1" df -kh | grep disk

# This checks the crontab schedule of the rsycn script
#ssh "$1" crontab -l | grep rsync_hourly.bash

#site_code=$(ssh "$1" head -1 /Codar/SeaSonde/Configs/RadialConfigs/Header.txt | awk '{print $2}')

#echo /$site_code/

# test key setup
#ssh "$1" 'df -kh .'

# get info about the site cpu
#ssh "$1" 'system_profiler | grep Model'
#ssh "$1" 'uname -m'

# get number of csq files
echo 'number of csqs in /Archives/Spectra/'
ssh "$1" 'ls -l /Codar/SeaSonde/Archives/Spectra/*CSQ* | wc -l'

# this tries to change Timezone but sudo is needed ...
ssh "$1" 'date'
#ssh "$1" 'sudo systemsetup -settimezone GMT'
#ssh "$1" 'date'

}
#-----------------------------------------------------------------------


# DEFINE SITE IP ALIASES


 sites=(
 "mgs1.dnsalias.com"
 "fbk1.no-ip.net"
 "sni1.dnsalias.com"
 "ptm1.dnsalias.com"
 "ssd1.dnsalias.com"
 "cop1.dnsalias.com"
 "rfg1.dnsalias.com"
 "nic1.dnsalias.com"
 "sci1.dnsalias.com"
 "luis.marine.calpoly.edu"
 "arg1.no-ip.net"
 "dcsr.no-ip.net"
 "dclr.no-ip.net"
 "agl1.no-ip.net"
 "estr.no-ip.net"
 "ragg.no-ip.net"
 "ptc1.no-ip.net")   



# RUN LOOP

for i in "${sites[@]}"
do
    echo %---------------------------------%
	echo $i	
	do_work $i
done	
	
	
