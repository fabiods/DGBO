#!/bin/bash
#set -x
# take in input a crystal file       with "*" for basis set optimization
# make in output a crytstal file.par with parameter string for optimization 

echo " --- From crystal input for optbasis to basrunopt ---"
name=$1
if [ "$name" == "" ]; then
    echo " ERROR: syntax"
    echo "cry2basrun.sh crystalfilename"
    exit
fi
# tmp is : exponent 1.000
grep -A 1 "*" $name |  grep -v "\-\-" | grep -v "*" > tmp

# type.dat is: momentoangolare
grep  "*" $name | awk '{if  ( $2 == "0" ) { print "S" } else { if ( $2 == "2" ) { print "P"} else {print "D"} } }' >type.dat

# sedfile.dat.tmp is : PAR1 X exponenente
grep -A 1 "*" $name |   grep -v "\-\-" | grep -v "*" | awk '{printf "%s%1d%s %f\n","PAR",NR," X",$1}' > sedfile.dat.tmp

# sedfile is # PAR1S exponente
paste type.dat sedfile.dat.tmp | awk '{printf "%s%s %f\n",$2,$1,$4}' > sedfile.dat
# -------------bounds-------------------------
~/DGBO/crylc.sh $name > crylc.out
#cat crylc.out

maxxs=`grep " S " crylc.out | awk '{print $2/1.5}'`
maxxp=`grep " P " crylc.out | awk '{print $2/1.5}'`
maxxd=`grep " D " crylc.out | awk '{print $2/1.5}'` 
echo "from deep contractions:"
echo "maxxs" $maxxs
echo "maxxp" $maxxp
echo "maxxd" $maxxd

declare -a myexp
declare -a myexppt
declare -a myexpdt
declare -a myexpa
declare -a mytyp
declare -a myexpdef

# tmp2 is : S	    expnenete   1.00000000000E+00
paste type.dat tmp > tmp2

num=`wc -l tmp2 |awk '{print $1}'`
numl=`echo $num | awk '{print $1+1}'`
index=1
while read -r line; do
    tt=`echo $line | awk '{print $1}'`
    #    ee=`echo $line | awk '{printf "%5.3E",$2}'`
    ee=`echo $line | awk '{printf "%f",$2}'`             
    if [ "$tt" == "S" ] && [ ! -z "$maxxs" ]; then
	eept=$maxxs
        myexpdef[$index]=1
    elif [ "$tt" == "P" ] && [ ! -z "$maxxp" ]; then
	eept=$maxxp
        myexpdef[$index]=1
    elif [ "$tt" == "D" ] && [ ! -z "$maxxd" ]; then
	eept=$maxxd
        myexpdef[$index]=1
    else	
        myexpdef[$index]=0 
#	eept=`echo $line | awk '{printf "%5.3E",$2*3}'`
	eept=`echo $line | awk '{print $2*4}'`         
    fi	
    #    eedt=`echo $line | awk '{printf "%5.3E",$2/2}'`
    # most diffuse exponents 
    eedt=`echo $line | awk '{printf "%20.10f",$2/4}'`
    eedtc=`echo "$eedt < 0.04" | bc -l`
    if [ "$eedtc" == "1" ]; then
	eedt=0.04 
    fi
    
    myexp[$index]=$ee
    myexppt[$index]=$eept
    myexpdt[$index]=$eedt
    mytyp[$index]=$tt
    
    index=$((index+1))
done < tmp2

echo "myexp:"
echo ${myexp[@]}

echo "myexp prima (defined only for first/last):"
echo ${myexppt[@]}

echo "myexp dopo (defined only for dirst/last):"
echo ${myexpdt[@]}

echo "myexp defined"
echo ${myexpdef[@]}

echo "mytyp:"
echo ${mytyp[@]}
echo "mytyp full:"
myexp[0]=100000
myexp[$numl]=0.0
mytyp[0]=""
mytyp[$numl]=""

echo ${myexp[@]}
echo "average:"
for ((k = 0 ; k <= $num ; k++ )); do
#    echo ${myexp[k]} ${myexp[k+1]} | awk '{ print sqrt($2*$1)}'
    myexpa[$k]=`echo ${myexp[k]} ${myexp[k+1]} | awk '{ print sqrt($2*$1)}' `
    echo $k ${myexpa[k]}
done
if [ -z $GMF ]; then
   echo "GMF not set in the environment" 
   GMF="%5.3E"
else
    echo "GMF: $GMF"
fi
    fmto=$GMF" "$GMF"\n"
echo $fmto
echo "Bounds: creating bounds.dat ... "
rm bounds.dat
for ((k = 1 ; k <= $num ; k++ )); do
    if [ "${mytyp[k-1]}" !=  "${mytyp[k]}" ]; then
	first="yes"
    else
	first="no"
    fi
    if [ "${mytyp[k]}" !=  "${mytyp[k+1]}" ]; then
	last="yes"
    else
	last="no"
    fi
#    echo $k,$first,$last
    if [ "$first" == "yes" ]; then
	echo $k,":",${myexpa[k]},"<",${myexp[k]},"<",${myexppt[k]}
	echo "${myexpa[k]} < ${myexp[k]}" | bc -l
	echo "${myexp[k]} < ${myexppt[k]}" | bc -l               
	vv=${myexpdef[k]}
	if [ "$vv" == "1" ]; then 
          echo ${myexpa[k]} ${myexppt[k]} | awk -v gm="$fmto" '{printf gm,$1,-$2}' >> bounds.dat
        else
          echo ${myexpa[k]} ${myexppt[k]} | awk -v gm="$fmto" '{printf gm,$1,$2}' >> bounds.dat
        fi
    else
	if [ "$last" == "yes" ]; then
            echo $k,":",${myexpdt[k]},"<",${myexp[k]},"<",${myexpa[k-1]}
	    echo "${myexpdt[k]} <  ${myexp[k]} " | bc -l  
	    echo "${myexp[k]} < ${myexpa[k-1]} " | bc -l
	    echo  ${myexpdt[k]} ${myexpa[k-1]} | awk -v gm="$fmto" '{printf gm,$1,$2}'>> bounds.dat
 
        else
	    #	    echo $k ${myexp[k+1]} ${myexp[k]} ${myexp[k-1]} | awk '{print $1,sqrt($2*$3),sqrt($3*$4)}'
	    echo $k,":",${myexpa[k]},"<",${myexp[k]},"<",${myexpa[k-1]}
	    echo "${myexpa[k]} < ${myexp[k]}"     | bc -l
	    echo "${myexp[k]} < ${myexpa[k-1]}"   | bc -l
	    echo  ${myexpa[k]} ${myexpa[k-1]} | awk -v gm="$fmto" '{printf gm,$1,$2}' >> bounds.dat
	fi    
    fi
    
done
cat bounds.dat
echo "Now creating $name.par ... "
# str sed
declare -a MYARRAY
index=1
while read -r line; do
    ss=`echo $line | awk '{print $1}'`
    MYARRAY[$index]=$ss
    echo $index, ${MYARRAY[index]}
    index=$((index+1))
done < sedfile.dat
echo ${MYARRAY[@]}
cp $name $name.par
c=0
while read -r line; do
    c=$((c+1))
    qqq=MYARRAY[$c]
    #    sed -i s/"$line"/"PAR"$c"X +1.0"/g $name.par
    sed -i s/"$line"/${MYARRAY[c]}" 1.0"/g $name.par 
done < tmp
