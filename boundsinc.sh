#!/bin/bash
#set -x
source ~/DGBO/basuty.sh
name=$1
#echo $GMF
# READ bound.dat and reformat it
while read -r line; do
    fmin=`echo $line | awk -v fmt=$GMF '{printf fmt,$1}'`
    fminx=`xprec $fmin $GMF`
    fmax=`echo $line | awk -v fmt=$GMF '{printf fmt,$2}'`
    fmaxx=`xnext $fmax $GMF`
    echo $fminx $fmaxx
done < $name
exit
#set -x
# from bounds.dat to boundsint.dat
sss=$GMF" "$GMF"\n"
#echo $sss
awk -v fmt="$sss" '{printf fmt,$1,$2}' $name > ttt
#cat ttt
awk -v fmt=$GMF   '{printf fmt"\n",$1}' $name > tttmin
awk -v fmt=$GMF   '{printf fmt"\n",$2}' $name > tttmax 

#awk -F E '{print "1E"$2} ' tttmin > ordgmin          
awk -F E '{ print "1E"$2} ' tttmax > ordgmax 
awk -F E '{if ( $1 != 1 ) {print "1E"$2} else {printf "%s%+2.2d\n","1E",($2-1)} }' tttmin > ordgmin
#cat ordgmin
#awk -F E '{if ( $1 != 9 ) { print "1E"$2} else {printf "%s%+2.2d\n","1E",($2+1)} }' tttmax > ordgmax
#         1     2     3  4
paste ordgmin ordgmax ttt | awk -v fmt="$sss" '{printf fmt,($3/$1-1)*$1,($4/$2+1)*$2}'
