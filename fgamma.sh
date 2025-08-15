#!/bin/bash
minr=`sort -k 3 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $3}'`
eneatminr=`sort -k 3 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $6}'` 
echo $minr $eneatminr

mine=`sort -k 6 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $6}'`  
rmaxatmine=`sort -k 6 -g -r notconv.dat  | grep -v NA | tail -n 1 | awk '{print $3}'`
echo $rmaxatmine $mine
ediff=`echo $mine $eneatminr | awk '{print ($1-$2)/2}'`
echo $ediff
#ediff = gamma *ln(rmax)
#ediff/ln(rmax)
gamma=`echo "$ediff/l($minr)"  | bc -l`
echo $gamma
gamma=`echo "$ediff/l($rmaxatmine)"  | bc -l`
echo $gamma
