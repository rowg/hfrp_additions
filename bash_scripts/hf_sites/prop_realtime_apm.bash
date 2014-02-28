#!/bin/bash
# PROPAGATE REALTIME APM CODE T
#
# Copy copiled code and MCR to remote sites
# Install cron jobs and needed directories
#
# Copyright (C) 2012 Brian Emery
#
#  		20 July 2012
#

#-----------------------------------------------------------------------
function do_work {
# DO WORK - run stuff on remote shells
# 
#
# INPUT: the site IP address or network alias


# make it up to date
rsync -avruzP --delete /home/codar/realtime_apm "$1":/Codar/SeaSonde/Apps/

# create directories
ssh "$1" mkdir /Codar/SeaSonde/Data/AIS/
ssh "$1" mkdir /Codar/SeaSonde/Data/AIS/TraksToProcess/
ssh "$1" mkdir /Codar/SeaSonde/Data/AIS/TraksProcessed/

# add to crontab
ssh "$1" 'crontab -l > ~/old_crontab'
ssh "$1" 'cp ~/old_crontab ~/new_crontab'
ssh "$1" 'echo "10      15      *       *       *       /Codar/SeaSonde/Apps/realtime_apm/realtime_apm_nice.bash" >> ~/new_crontab'
ssh "$1" 'crontab ~/new_crontab'

}
#-----------------------------------------------------------------------


# DEFINE SITE IP ALIASES

sites=("sni1.dnsalias.com")
#sites=("nic1.dnsalias.com")

#sites=("sni1.dnsalias.com"
#       "ptm1.dnsalias.com"
#       "rfg1.dnsalias.com"
#       "arg1.no-ip.net"
#	"mgs1.dnsalias.com"
#	"fbk1.no-ip.net"
#	"ssd1.dnsalias.com"
#	"cop1.dnsalias.com")


#sites=("iog.msi.ucsb.edu")
# "luis.marine.calpoly.edu"
# "arg1.no-ip.net"
# "dcsr.no-ip.net"
# "dclr.no-ip.net"
# "agl1.no-ip.net"
# "estr.no-ip.net"
# "ragg.no-ip.net"
#         "arg1.no-ip.net"
#         "agl1.no-ip.net"


# RUN LOOP

for i in "${sites[@]}"
do
    echo %---------------------------------%
	echo $i	
	do_work $i
done	
	
	
