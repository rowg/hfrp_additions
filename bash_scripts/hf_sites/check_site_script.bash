#!/bin/bash
# PROPAGATION SCRIPT
#
# Copy keys, etc to remote sites
#
# Copyright (C) 2012 Brian Emery
#
#  		20 July 2012
#
# Copy this from local to stokes where it should be run:
# rsync -avr /projects/hf_sites/ stokes:/home/codar/scripts/hf_sites/

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
#ssh "$1" df -kh | grep disk

# This checks the crontab schedule of the rsycn script
#ssh "$1" crontab -l | grep rsync_hourly.bash

#site_code=$(ssh "$1" head -1 /Codar/SeaSonde/Configs/RadialConfigs/Header.txt | awk '{print $2}')

#echo /$site_code/

# test key setup
echo space:
ssh "$1" 'df -kh .'

# get info about the site cpu
echo OS:
ssh "$1" 'system_profiler | grep OS'
#ssh "$1" 'uname -m'

# get number of csq files
#echo 'number of csqs'
#ssh "$1" 'ls -l /Codar/SeaSonde/Archives/Spectra/*CSQ* | wc -l'

# this tries to change Timezone but sudo is needed ...
#ssh "$1" 'date'
#ssh "$1" 'sudo systemsetup -settimezone GMT'
#ssh "$1" 'date'

# get archivalist version
#ssh "$1" '/Codar/SeaSonde/Apps/Bin/GetVersion /Codar/SeaSonde/Apps/radialtools/Archivalist.app/'

# get number of files in folders
echo CSS
ssh "$1" 'ls -l /Codar/SeaSonde/Data/Spectra/SpectraProcessed/ | wc -l'

echo CSQ
ssh "$1" 'ls -l /Codar/SeaSonde/Data/Spectra/SpectraSeriesProcessed/ | wc -l'

echo  RNG
ssh "$1" 'ls -l /Codar/SeaSonde/Data/RangeSeries/ | wc -l'

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
 "ptc1.dnsalias.com")   



# RUN LOOP

for i in "${sites[@]}"
do
    echo %---------------------------------%
	echo $i	
	do_work $i
done	
	
	
