#!/bin/bash
#set -x
source ~/DGBO/basuty.sh


numpar=$#
if [ -z $GMF ]; then
    GMF="%5.3E"
fi

if [ ! -e inputhf.d12.par ];  then
    echo "inputhf.d12.par not found"
    exit
fi

LOGFILE="basrun.log"

SILENT="yes"

if [ "$numpar" -ne 0 ]; then 
 rm tmpsed
 for var in "$@"
 do
    echo "$var" >> tmpsed
 done
# tmpsed can be wITHOUT GMF format

 if [ ! -e tmpsed2 ]; then
    # this is alwats the same
    grep PAR inputhf.d12.par > tmpsed2
 fi

 lpar=`wc -l tmpsed2 | awk '{print $1}'`
 if [ "$lpar" != "$numpar" ]; then
   echo "different par" $lpar $numpar
   exit
 fi   
paste tmpsed2 tmpsed | awk '{print $1,$3}' > basrunsed.dat
else
    echo "using basrunsed.dat" >> $LOGFILE
    if [ ! -e basrunsed.dat ]; then
	echo "basrunsed.dat not found" >> $LOGFILE
	exit
    fi
    cat basrunsed.dat  >> $LOGFILE
fi    

#rm $LOGFILE >& /dev/null
#set -x
  
#echo $numpar
#if [ "$numpar" == "1" ]; then
#parone=$1
#elif [ "$numpar" == "2" ]; then
#parone=$1
#partwo=$2
#elif [ "$numpar" == "3" ]; then
#	 parone=$1
#	 partwo=$2
#	 parthr=$3
#	 
#fi	 

LISTENE='basrun.allene.dat'

#rm $LISTENE >& /dev/null

#if [ "$numpar" == "2" ]; then
#echo "PAR1D" $parone > sedfile.dat
#echo "PAR2D" $partwo >> sedfile.dat
#elif [ "$numpar" == "3" ]; then
#echo "PARONE" $parone > sedfile.dat
#echo "PARTWO" $partwo >> sedfile.dat
#echo "PARTHR" $parthr >> sedfile.dat
# fi
echo $GMF >> $LOGFILE	
cp inputhf.d12.par inputhf.d12

told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%30.10f",$1}'`
echo "tol" $told $tol $tolb >> $LOGFILE
if [ -e "gamma.info" ]; then
   gamma=`cat gamma.info`
   else
   gamma=0    
fi
   echo "gamma" $gamma >> $LOGFILE

sedinput basrunsed.dat -1 -1

#----------check------------range---------
if [ "1" -eq "0" ]; then 
 grep "S " basrunsed.dat > bass.tmp
 nxs=`wc -l bass.tmp | awk '{print $1}'`
 tail -n+2 bass.tmp > bass.tmp.1
 head -n-1 bass.tmp > bass.tmp.l
 paste bass.tmp.l bass.tmp.1 | awk '{ if ($2/$4 <1.7) {print "ERR"} else {print $2/$4}}' > bass.err
 nxs=0
 nxs=`grep ERR bass.err | wc -l | awk '{print $1}'`
 echo $nxs >>$LOGFILE

 grep "P " basrunsed.dat > basp.tmp
 nxp=`wc -l bass.tmp | awk '{print $1}'`
 tail -n+2 basp.tmp > basp.tmp.1
 head -n-1 basp.tmp > basp.tmp.l
 paste basp.tmp.l basp.tmp.1 | awk '{ if ($2/$4 <1.7) {print "ERR"} else {print $2/$4}}' > basp.err
 nxp=0
 nxp=`grep ERR basp.err | wc -l | awk '{print $1}'`
 echo $nxp >>$LOGFILE

 grep "D" basrunsed.dat > basd.tmp
 nxd=`wc -l basd.tmp | awk '{print $1}'`
 tail -n+2 basd.tmp > basd.tmp.1
 head -n-1 basd.tmp > basd.tmp.l
 paste basd.tmp.l basd.tmp.1 | awk '{ if ($2/$4 <1.7) {print "ERR"} else {print $2/$4}}' > basd.err
 nxd=0
 nxd=`grep ERR basd.err | wc -l | awk '{print $1}'`
 echo $nxd >> $LOGFILE
 echo $nxs $nxp $nxd >> $LOGFILE
 nxtot=`echo $nxs $nxp $nxd | awk '{print $1+$2+$3}' `
 echo "nxtot" $nxtot >> $LOGFILE
else
    echo " ~/DGBO/checkbr.x $dstr > br.out" >>$LOGFILE
    ~/DGBO/checkbr.x $dstr > br.out
    nxtot=`grep ierr br.out | awk '{print $2}'`
    echo "nxtot" $nxtot >> $LOGFILE
fi


runcrycond  out.$str $nxtot
echo $ene $enevera

