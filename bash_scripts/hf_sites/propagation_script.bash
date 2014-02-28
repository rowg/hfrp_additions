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



# SETUP NEW SITE FOR AUTOMATED FILE TRANSFER
# All this stuff copies from the local folder to the remote

## cat public key to remote site auth keys file
#cat /home/codar/.ssh/id_dsa.pub | ssh "$1" 'cat >> /Users/codar/.ssh/authorized_keys'

# copy config file
#scp config "$1":~/.ssh/

# copy site private key
#scp id_dsa_hfsites "$1":~/.ssh/

# set file permissions
#ssh "$1" chmod 600 /Users/codar/.ssh/id_dsa_hfsites



# COPY RSYNC SCRIPTS
# make new directory
ssh "$1" mkdir /Codar/SeaSonde/Apps/Scripts/obsolete/

# move old scripts there
ssh "$1" mv /Codar/SeaSonde/Apps/Scripts/rsync_hourly.bash /Codar/SeaSonde/Apps/Scripts/obsolete/

# copy NEW rsync script into place
scp rsync_hourly.bash "$1":/Codar/SeaSonde/Apps/Scripts/

# set file permissions
ssh "$1" chmod 777 /Codar/SeaSonde/Apps/Scripts/rsync_hourly.bash


# COPY SSACq settings
#scp  /home/codar/scripts/hf_sites/site_configs/Archivalist_Export_11_2_9.plist "$1":/Codar/SeaSonde/Configs/RadialConfigs/Archivalist.plist

# Add lines to bash profiles too!

# add line to crontab
# in this case, a daily rsync of Archives to the backup drive
#ssh "$1" 'crontab -l > ~/old_crontab'
#ssh "$1" 'cp ~/old_crontab ~/new_crontab'
#ssh "$1" 'echo "1      15      *       *       *      rsync -avr /Codar/SeaSonde/Archives/ /Volumes/CodarArchives/Archives/" >> ~/new_crontab'
#ssh "$1" 'crontab ~/new_crontab'




# test key setup
#ssh "$1" 'df -kh .'
}
#-----------------------------------------------------------------------


# DEFINE SITE IP ALIASES

# still need to do COP
#sites=("cop1.dnsalias.com")
#       "mgs1.dnsalias.com")


#sites=("nic1.dnsalias.com"
#  "mgs1.dnsalias.com"
#  "ptm1.dnsalias.com"
#  "ssd1.dnsalias.com"
#  "rfg1.dnsalias.com"
#  "sci1.dnsalias.com"
#  "fbk1.no-ip.net"
#  "ptc1.no-ip.net"
#  "sni1.dnsalias.com"
#  "cop1.dnsalias.com"
#  "luis.marine.calpoly.edu")

# DONE

sites=( "arg1.no-ip.net"
        "dcsr.no-ip.net"
        "dclr.no-ip.net"
        "agl1.no-ip.net"
        "estr.no-ip.net"
        "fbk1.no-ip.net"       
        "ragg.no-ip.net")




# RUN LOOP

for i in "${sites[@]}"
do
    echo %---------------------------------%
	echo $i	
	do_work $i
done	
	
	
