#!/bin/bash
#-----------------------------------------------------------------------#
# RSYNC HOURLY - data push from remote sites
#
# Designed to be run on remote site computers from an hourly cron job. This
# script - Moves radials, diagnostic files, and log files to the central site
#        - Mirrors archive drives (CodarArchives and CodarArchives2)
#
# Requires 'euler' and 'stokes' to be defined in .ssh/config
#
# Rsync switch explanations:
# -t, --times                 preserve times 
# -u, --update                update only (don't overwrite newer files)
# -v, --verbose
# -z, --compress              compress file data 
# -P     The  -P  option is equivalent to --partial --progress.
# -E, --extended-attributes   Apple specific option  to  copy  extended  
# attributes, resource forks,  and  ACLs. 
# -T  --temp-dir=DIR          create temporary files in directory DIR
#
# Brian Emery 6 Oct 2008 from other scripts 
# Requires no modification for installation on remote site computers!
#
# Updates: 18 Mar 2011, ssh tunnel to stokes via euler
#	               added function to simplify code
#          20 Jul 2012 documented tunnel key setup, incorp use of 
#                  ssh config file
#          22 Oct 2012 new paths for new stokes server
#          28 Jan 2014 test for site_code and lock file
#
# CRON CALL
# /Codar/SeaSonde/Apps/Scripts/rsync_hourly.bash
# 
# TEST TUNNELING
# rsync -av -e "ssh euler ssh" test.txt stokes:/home/codar/
#
# TEST DECODED FORM
# run this as one line:
# rsync -tuvzPr --chmod=ugo=rwx --delete --temp-dir=/home/codar/tmp/ -e "ssh euler ssh -q" /Volumes/CodarData/Codar/SeaSonde/Data/Diagnostics/ stokes:/data/diagnostics/sni1/
#

#-----------------------------------------------------------------------#

#-----------------------------------------------------------------------#
function rsync_job {
# RSYNC JOB
# Functional form of rsync command. The command has the form:
# cmd localDir remoteDir >> logFile
# The -e switch enables an ssh tunnel to the destination machine behind
# a fire wall
#
# INPUTS
# One input is captured and used as the source and destination directory
# (options are Radials, Diagnostics and Logs
#
# Brian Emery

# DEFINE LOCAL LOG FILE
rsync_log=/Volumes/CodarData/Codar/SeaSonde/Logs/rsync_hourly.log

# CREATE LOCAL DIRECTORY NAME
if [[ "$1" == "Logs" ]] ; then
 local_dir=/Volumes/CodarData/Codar/SeaSonde/"$1"/
else
 local_dir=/Volumes/CodarData/Codar/SeaSonde/Data/"$1"/
fi

# Convert input to lower case
folder="$(tr [A-Z] [a-z] <<< "$1")"


# GET SITE CODE
site_code=$(head -1 /Codar/SeaSonde/Configs/RadialConfigs/Header.txt | awk '{print $2}')



# RUN RSYNC COMMAND

# check that site code is NOT empty
# NOTE: despite testing, I'm not really sure this works because I don't know exactly why the
# sites sometimes get an empty site_code, and if it's truely empty

if [[ -n "$site_code" ]]; then

	# uses 'euler' and 'stokes' as defined in .ssh/config
	rsync -tuvzPr --chmod=ugo=rwx --delete --temp-dir=/home/codar/tmp/ -e "ssh euler ssh -q"\
		"$local_dir" stokes:/data/"$folder"/"$site_code"/\
        	>> "$rsync_log" 2>> "$rsync_log"

fi
}
#-----------------------------------------------------------------------#

# DEFINE VARIABLES OUTSIDE FUNCTION
rsync_log=/Volumes/CodarData/Codar/SeaSonde/Logs/rsync_hourly.log

# Make the log file readable
echo %---------------------------------% >> "$rsync_log" 
echo START Running rsync_hourly.bash  >> "$rsync_log"
date   >> "$rsync_log" 2>> "$rsync_log"

# TEST FOR LOCKFILE
# checks for it, exits if it's there
lockfile -r 0 /tmp/the.lock || exit 1


# RADIALS
echo RADIALS: >> "$rsync_log" 2>> "$rsync_log" 
rsync_job Radials 

echo STATS: >> "$rsync_log" 2>> "$rsync_log" 
rsync_job Diagnostics

echo LOGS: >> "$rsync_log" 2>> "$rsync_log" 
rsync_job Logs

echo LOOPS: >> "$rsync_log" 2>> "$rsync_log"
rsync_job Loops


# MIRROR ARCHIVE DRIVES
# check to prevent unintended 'mirroring'
if [ -d /Volumes/CodarArchives2 ] ; then
   echo Mirror Archive Drives: >> "$rsync_log" 2>> "$rsync_log" 
   rsync -av /Volumes/CodarArchives/ /Volumes/CodarArchives2/ >> "$rsync_log" 2>> "$rsync_log"
 else
   echo ARCHIVE 2 NOT FOUND >> "$rsync_log" 2>> "$rsync_log"
fi

# Remove the lock file
rm -f /tmp/the.lock

# put a time stamp at the end
date   >> "$rsync_log" 2>> "$rsync_log"
echo END >> "$rsync_log" 2>> "$rsync_log"



