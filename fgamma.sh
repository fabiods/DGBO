#!/bin/bash
if [ -e "maxrmax.info" ]; then
   maxrmax=`cat maxrmax.info`
   else
   maxrmax=10000    
fi
echo "maxrmax" $maxrmax

minr=`sort -k 3 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $3}'`
eneatminr=`sort -k 3 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $6}'` 
echo $minr $eneatminr

mine=`sort -k 6 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $6}'`  
rmaxatmine=`sort -k 6 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $3}'`
echo $rmaxatmine $mine

# debug
#rmaxatmine=2500
#echo $rmaxatmine $mine

# the final cond minimu is the one at min rmax if rmaxatmin > maxrmax/2
#                       otherwise is the other
xg=`echo "$rmaxatmine > $maxrmax/2" | bc -l`
echo "too much" $xg
#if [ "$xg" == "1" ]; then
    rrr=`echo $maxrmax | awk '{print $1/2}'`
#else
#    rrr=$rmaxatmine 
#fi
echo $rrr


ediff=`echo $mine $eneatminr | awk '{print (-$1+$2)}'`
echo "enediff:" $ediff
#ediff = gamma *ln(rmax)
#ediff/ln(rmax)
gammao=`echo "$ediff/l($rrr/$minr)"  | bc -l`
echo $gammao
#gammat=`echo "$ediff/l($rmaxatmine)"  | bc -l`
#echo $gammat

gammaof=`echo $gammao | awk '{printf "%2.0E\n",$1}' | awk '{printf "%8.5f",$1}'`
echo "GAMMA FINAL" $gammaof
echo "$eneatminr+$gammaof*l($minr)"   | bc -l
echo "$mine     +$gammaof*l($rmaxatmine)"  | bc -l 
