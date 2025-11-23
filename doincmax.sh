#!/bin/bash
move=$1
grep incmax td.dat |sort -k 2 -g -r > list.incmax
ttol=0.0000001
while read -r line; do
    lone=`echo $line |  awk '{print $2}'`
    ltwo=`echo $line |  awk '{print $3}'`

    chdetot=`echo "sqrt($lone*$lone) <= $ttol" | bc -l`
    # this is zero, because it is not converegd !
    chdetotwo=`echo "sqrt($ltwo*$ltwo) <= 10*$ttol" | bc -l`  
    echo $lone $chdetot $ltwo $chdetotwo
    if [ "$chdetot" == "1" ] && [ "$chdetotwo" == "1" ]; then
	file=`echo $line | awk '{print $1}'`
	echo $file
 	 if [ "$move" == "MOVE" ]; then
	  mv $file reallyconv
	 fi  
    fi
done < list.incmax  
