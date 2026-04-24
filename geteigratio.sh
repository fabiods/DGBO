#!/bin/bash
#set -x
LOGFILE="my.log"
silent="yes"
source ~/DGBO/basuty.sh

eigratio $1 $1

cat $1.eigs.rmax
