#!/bin/bash
#set -x
source ~/DGBO/basuty.sh
name=$1
bmaxname=$2
#echo $GMF
# READ bound.dat and reformat it
kk=0
if [ ! -e $bmaxname ]; then
 echo $bmaxname "not found"
 exit
fi
if [ ! -e $name ]; then
 echo $name "not found"
 exit
fi

paste $name $bmaxname > tmp
while read -r line; do
    
    gmin=`echo $line | awk '{printf "%f",$1}'`
    gmax=`echo $line | awk '{printf "%f",$2}'`
    bmax=`echo $line | awk '{print $4}'`
    if [ "$bmax" != "0" ]; then 
    bmax=`echo $line | awk '{printf "%f",$4}'`
    fi
#    echo $gmin $gmax $bmax
    gminneg=`echo "$gmin < 0" | bc -l`
    gmaxneg=`echo "$gmax < 0" | bc -l`
    if [ "$gminneg" == "0" ]; then
     fmin=`echo $gmin | awk -v fmt=$GMF '{printf fmt,$1}'`
     fminx=`xprec $fmin $GMF 0`
    else
     fminx=$gmin	
    fi
    if [ "$gmaxneg" == "0" ]; then 
     fmax=`echo $gmax | awk -v fmt=$GMF '{printf fmt,$1}'`
     fmaxx=`xnext $fmax $GMF $bmax`
    else
#     fmaxx=$gmax	
#     domina bmax
      fmaxx=`echo $bmax | awk -v fmt=$GMF '{printf fmt,-$1}'`
    fi	
    echo $fminx $fmaxx
done < tmp

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
