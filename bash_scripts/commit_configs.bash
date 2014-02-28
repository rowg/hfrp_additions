#!/bin/bash
#-----------------------------------------------------------------------#
# COMMIT CONFIGS
# Script committing configs data to a mercurial revision control system
# on a regular schedule

# Copyright (C) 2013 Brian Emery 


# DEFINE LOG FILE
rsync_log="/home/codar/web_data/logs/commit_configs.log"

# Get time and date
DATE=`date`

# TIME STAMP LOG FILE

echo ----------------------------------------------------- >> "$rsync_log"
echo START Running /home/codar/scripts/commit_configs.bash  >> "$rsync_log"
date   >> "$rsync_log"

hg addremove -R /data/configs/ >> "$rsync_log"  
hg commit -m "Automated commit @ $DATE" -R /data/configs/ >> "$rsync_log"

 
