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
LOGFILE='basderfol.log'
rm $LOGFILE
echo "---- bas der fol ---"  | tee -a $LOGFILE
numpar=$#
if [ -z $GMF ]; then
    echo "GMF NOT DEFINED" | tee -a $LOGFILE 
    GMF="%5.3E"
fi
echo "GMF" $GMF | tee -a $LOGFILE 

if [ ! -e inputhf.d12.par ];  then
    echo "inputhf.d12.par not found"
    exit
fi

told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%15.10f",$1}'`

echo 'tol', $told $tol $tolb >> $LOGFILE

if [ ! -e  'basrunsed.dat' ]; then
	echo "cannot found basrunsed.dat"
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
    npart=`wc -l basrunsed.dat | awk '{print $1*2}'`
    echo "npart" $npart >> $LOGFILE
    conv="no"
    cnt=0
    echo "Starting cycles:" | tee -a $LOGFILE
#    rm basderfol.energy
  while [ "$conv" == "no" ] && [ "$cnt" -lt "$npart" ]; do
    cp basrunsed.dat basrunsed.dat.$cnt	 
    
    ~/DGBO/basdergmf.sh > yyy.$cnt
    cat basdergmf.log >> $LOGFILE
    
    rrr=`grep enezero yyy.$cnt | awk '{print $2}'`
    echo "cycle= " $cnt "energy= " $rrr
    echo $cnt $rrr > basderfol.energy
#                1     2   3        
#               ene   pos diff    
#     ENEDIFF 16.9502 3 1E+00
    vv=`grep ENEDIFF yyy.$cnt | awk '{ if ( $2 < 0.0) {print $2,$3,$4}}' | sort -k 1 -g | head -n 1`
    cnt=$((cnt+1)) 
#    echo $vv
    newpos=`echo $vv | awk '{print $2}'`
    newxxx=`echo $vv | awk '{print $3}'`
    newdif=`echo $vv | awk '{printf "%30.10f",$1}'`  
    if [ -z $newpos ]; then
	conv="yes"
    else
	echo $newpos $newxxx $newdif 
	isok=`echo "sqrt($newdif*$newdif) > $tolb*5" | bc -l`
        if [ "$isok" == "1" ] ; then
	awk -v pp=$newpos -v vv=$newxxx '{ if ( NR-1 == pp ) {print $1,vv} else {print $1,$2}}' basrunsed.dat > new
	mv new basrunsed.dat
	else
	    echo "too small variation" $newdif
	    conv="yes"
	fi    
    fi 	
  done
    echo "lastdiff" $newdif
	
    str=`awk 'BEGIN {printf "["}  { printf "%s ",$2} END {printf "]\n"} ' basrunsed.dat `
	nc=`grep notconv basderfol.log  | tail -n 1| awk '{print $3}'`
    nm=`grep minimum basderfol.log  | tail -n 1| awk '{print $3}'`

    echo " res: energy:" $rrr "dstr:" $str  "min:" $nm "conv:" $nc
