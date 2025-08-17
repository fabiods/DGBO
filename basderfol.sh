#!/bin/bash
#set -x
# input: GMF
#        basrunsed.dat
#        inputhf.d12.par
# output:  basrunsed.dat  (new)
#          basderfol.log
#          basderfol.energy
#          yyy.?
#          basrunsed.dat.?
#          APPEND to allene.dat
#          APPEND to notconv.dat
#          basdergmf.log  (last cycle)
#          gradinet.basrunsed.dat (last cycle)

if [ -e "gamma.info" ]; then
   gamma=`cat gamma.info`
   else
   gamma=0    
fi

LOGFILE="basderfol.$gamma.log"
rm $LOGFILE
echo "gamma" $gamma >> $LOGFILE

echo "---- bas der fol ---"  | tee -a $LOGFILE
numpar=$#
if [ -z $GMF ]; then
    echo "GMF NOT DEFINED" | tee -a $LOGFILE 
    GMF="%5.3E"
fi
echo "GMF" $GMF | tee -a $LOGFILE 

if [ ! -e inputhf.d12.par ];  then
    echo "inputhf.d12.par not found"  | tee -a $LOGFILE
    exit
fi

told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%15.10f",$1}'`

echo 'tol', $told $tol $tolb >> $LOGFILE

if [ ! -e  'basrunsed.dat' ]; then
	echo "cannot found basrunsed.dat"  | tee -a $LOGFILE
	exit
fi
    echo "input basrunsed.dat" | tee -a $LOGFILE
    cat basrunsed.dat | tee -a $LOGFILE    
    sss="%s "$GMF"\n" 
	
    awk -v fmt="$sss" '{printf fmt,$1,$2}' basrunsed.dat >tmt
    mv basrunsed.dat basrunsed.dat.old
    mv tmt basrunsed.dat
	
    echo "formatted basrunsed.dat" | tee -a $LOGFILE    
    cat basrunsed.dat | tee -a $LOGFILE 
	
    # max number of cycles param*10
    npart=`wc -l basrunsed.dat | awk '{print $1*20}'`
    echo "npart" $npart >> $LOGFILE
	
    conv="no"
    cnt=0
    echo "Starting cycles:" | tee -a $LOGFILE
#    rm basderfol.energy
  while [ "$conv" == "no" ] && [ "$cnt" -lt "$npart" ]; do
    cp basrunsed.dat basrunsed.dat.$cnt	 
    
    ~/DGBO/basdergmf.sh > yyy.$cnt
    echo               >> $LOGFILE
	echo "DERGMF START {" >> $LOGFILE
    cat basdergmf.log >> $LOGFILE
    echo "}DERGMF END}" >> $LOGFILE
	echo              >>$LOGFILE
 
    rrr=`grep enezero yyy.$cnt | awk '{print $2}'`
	echo >> $LOGFILE
    echo "cycle= " $cnt "energy= " $rrr | tee -a $LOGFILE
    echo >> $LOGFILE
	
    echo $cnt $rrr > basderfol.energy
#                1     2   3        
#               ene   pos diff    
#     ENEDIFF 16.9502 3 1E+00

    grep minimum yyy.$cnt
    vv=`grep ENEDIFF yyy.$cnt | awk '{ if ( $2 < 0.0) {print $2,$3,$4}}' | sort -k 1 -g | head -n 1`
	
    cnt=$((cnt+1)) 
#    echo $vv
    newpos=`echo $vv | awk '{print $2}'`
    newxxx=`echo $vv | awk '{print $3}'`
    newdif=`echo $vv | awk '{printf "%30.10f",$1}'`  
    if [ -z $newpos ]; then
	 conv="yes"
    else
#	 echo $newpos $newxxx $newdif 
	 isok=`echo "sqrt($newdif*$newdif) > $tolb*5" | bc -l`
        if [ "$isok" == "1" ] ; then
	     awk -v pp=$newpos -v vv=$newxxx '{ if ( NR-1 == pp ) {print $1,vv} else {print $1,$2}}' basrunsed.dat > new
	     mv new basrunsed.dat
	      ddd=`awk -v fmt=$GMF '{printf fmt" ", $2}' basrunsed.dat`
	    else
	     echo "too small variation" $newdif
	     conv="yes"
	    fi    
	     echo $newpos $newxxx $newdif $conv $ddd
    fi 	
  done
  if [ "$cnt" == "$npart" ]; then
    echo "MAX NUMBER OF CYCLES" | tee -a $LOGFILE
  fi	
#    echo "lastdiff" $newdif
	
    str=`awk 'BEGIN {printf "["}  { printf "%s ",$2} END {printf "]\n"} ' basrunsed.dat `
	nc=`grep notconv $LOGFILE  | tail -n 1| awk '{print $2}'`
    nm=`grep minimum $LOGFILE  | tail -n 1| awk '{print $2}'`

    echo " energy:" $rrr "dstr:" $str  "min:" $nm "conv:" $nc
