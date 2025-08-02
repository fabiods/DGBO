#!/bin/bash
source  ~/DGBO/basuty.sh

#set -x
# from bounds.dat to boundsint.dat
if [ "$GMF" == "%2.0E" ]; then
    dec=1
elif [ "$GMF" == "%3.1E" ]; then
    dec=0.1
elif [ "$GMF" == "%4.2E" ]; then
    dec=0.01
elif [ "$GMF" == "%5.3E" ]; then
    dec=0.001
fi

sss=$GMF" "$GMF"\n"
#echo $sss
awk -v fmt="$sss" '{printf fmt,$1,$2}' bounds.dat > ttt
awk -v fmt=$GMF   '{printf fmt"\n",$1}' bounds.dat > tttmin

awk -F E  '{print "1E"$2}' tttmin > ordg
awk -v d=$dec '{print $1*d}' ordg > ordgdec
awk -v d=1 '{print $1*d}' ordg > ordgdec0

paste ordg ttt | awk -v d=$dec '{print $2/$1/d,$3/$1/d}'
