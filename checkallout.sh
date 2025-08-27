#!/bin/bash
#set -e
set -u
source ~/DGBO/basuty.sh
if [ $# -ge 1 ]; then
    move=$1
else
    move="NO"
fi
echo "move:" $move
if [ -e inputhf.d12.par ]; then
    told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
else
    told=7
fi    
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%30.10f",$1}'`
find . -maxdepth 1 -iname "out*"  | xargs ls  | grep -v eigs | grep -v ene > listout
#dir out* | grep -v eigs | grep -v ene > listout
#head -n 1000 listout > listout1000
wc -l listout
LOGFILE="checkallout.log"
rm $LOGFILE
echo $tolb | tee -a $LOGFILE
wc -l listout    | tee -a $LOGFILE
mkdir removed >& /dev/null
mkdir notconv >& /dev/null
mkdir openerr >& /dev/null
mkdir inccyc  >& /dev/null
mkdir bohc >& /dev/null
rm td.dat
echo "                                   waserr , toomany ,  chdetot , chdetotv, chktst , chklla , chkdiis, ene   " | tee -a $LOGFILE   
openerr=0
notconvnormal=0
incc=0
tuttok=0
diisfail=0
okbuttst=0
bohc=0
waserrc=0
rm notconvall.dat
rm rtime.dat
while read -r line; do
#    echo $line
    isopenerr=0    
    enemay=0
    err=`grep INPBAS $line | wc -l | awk '{print $1}'`
    ett=`grep INPUTT $line | wc -l | awk '{print $1}'`
    ela=`grep "INCREASE ILASIZE" $line | wc -l | awk '{print $1}'`  
    if [ "$err" -ne "0" ] || [ "$ett" -ne "0" ] ||  [ "$ela" -ne "0" ]; then
	grep -H INPBAS $line
	echo $err $ett $ela | tee -a $LOGFILE   
	ls -al $line
	rm $line
#	exit
    else
#     echo $line
	getenefromout $line $tolb "yes" "no"
    timef=`grep "TTTTT END         TELAPSE" $line | awk '{print $4}'`
#	echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene 
	# tma too many cicles not considered
	if [ "$waserr" == "no" ]; then
	if [ "$chdetotv" != "1" ] || [ "$chktst" != "1" ] || [ "$chklla" != "1" ] ||  [ "$chkdiis" != "1" ]; then
	    if [ "$tma" == "0" ] && [ "$chdetotv" == "1" ] && [ "$chktst" == "0" ] && [ "$chklla" == "1" ] &&  [ "$chkdiis" == "1" ]; then
		#   		echo $line , $waserr , $tma , $chdetot , $chktst , $chklla , $chkdiis, $ene
		# tutto ok ma test alto
		aa=1
		okbuttst=$((okbuttst+1))
		str="okbuttst"

	    elif [ "$chdetotv" == "0" ] && [ "$chklla" == "1" ] &&  [ "$chkdiis" == "1" ]; then
		#               no ,     0      , 1 , 1 , 1 , 0,
		openerr=$((openerr+1))
		isopenerr=1
		echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene          | tee -a $LOGFILE   
#    		grep DETOT $line | tail -n 5
#		echo " -----------THIS IS OPENMP  BUG----------" $openerr
		str="openerr"
	    elif [ "$tma" == "1" ] && [ "$chdetotf" == "0" ]; then
		notconvnormal=$((notconvnormal+1))
#		echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene
#		grep DETOT $line | tail -n 5
#		echo " ----- THIS IS NORMAL NOT CONVERGECE----" $notconvnormal
                str="normalnotconv"
		
	    elif [ "$chdetot" == "1" ] && [ "$chklla" == "1" ] &&  [ "$chkdiis" == "0" ]; then 
		echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene | tee -a $LOGFILE   
		grep DETOT $line | tail -n 5
		diisfail=$((diisfail+1))
                 echo " ----- ONLY DIIS FAILED----"   $diisfail | tee -a $LOGFILE   
                 str="diisfail"

	    elif  [ "$tma" == "1" ] && [ "$chdetotf" == "1" ]; then
		echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene | tee -a $LOGFILE   
		grep DETOT $line | tail -n 5
                enemay=`grep DETOT $line | tail -n 1  | awk '{print $4}'`
                incc=$((incc+1))
		echo " ----- MAYBE INCREAS MAXCYCLE----" $incc | tee -a $LOGFILE   
		if [ "$move" == "MOVEINCCYC" ] || [ "$move" == "MOVE" ]; then
		    echo "mv $line inccyc" | tee -a $LOGFILE   
                    mv $line inccyc
		fi
		str="incmax"
#	     elif [ "$chdetotv" == "0" ] && [ "$chklla" == "1" ]; then	
	    else
		echo $line , $waserr , $tma , $chdetot , $chdetotv, $chktst , $chklla , $chkdiis, $ene | tee -a $LOGFILE   
		bohc=$((bohc+1))
		echo " -- boh == " $bohc | tee -a $LOGFILE  
       if [ "$move" == "MOVEBOHC" ] || [ "$move" == "MOVE" ]; then
             echo "mv $line bohc" | tee -a $LOGFILE
                   mv $line bohc
	   fi			   
                str="boh"  
		#		exit
	    fi
	else
	    # echo tutto convegente
	    aa=1
	    tuttok=$((tuttok+1))
	    str="ok"
        fi #almenounofuori
	else
	    str="err"
	    waserrc=$((waserrc+1))
	fi #waserr
	
    if [ "$waserr" == "yes" ]; then
#	tail -n 10 $line
	echo "mv $line removed " | tee -a $LOGFILE   

	if [ "$move" == "MOVE" ]; then
	    mv $line removed
	fi    
    fi
    
    if [ "$ene" == "NA" ]; then
     #|| [ "$chkdiis" == "0" ]; then
#	tail -n 10 $line
	echo "mv $line notconv" | tee -a $LOGFILE   
#	exit
	if [ "$move" == "MOVE" ]; then
	    mv $line notconv
	fi    
    fi

    if [ "$isopenerr" == "1" ]; then
	echo "mv $line openerr"  | tee -a $LOGFILE   
	if [ "$move" == "MOVE" ]; then 
	    mv $line openerr
	fi    
    fi
    
    fi
    #    exit
     echo $line $detota $llaa $tst $diis $enemay "|" $waserr  $tma  $chdetot $chdetotv,  $chktst  $chklla  $chkdiis $ene $str  >> td.dat 
	 rmax=`cat $line.eigs.rmax | awk '{print $2}'`
     echo "rmax rmax0" $rmax $rmax $ene $ene $line >> notconvall.dat
	 echo $rmax $time >> rtime.dat
done <listout
wc -l listout
echo "tuttok" $tuttok | tee -a $LOGFILE   
echo "openerr" $openerr | tee -a $LOGFILE   
echo "notconvnormal" $notconvnormal | tee -a $LOGFILE   
echo "inccyc" $incc | tee -a $LOGFILE   
echo "diisfail" $diisfail | tee -a $LOGFILE   
echo "okbuttst" $okbuttst | tee -a $LOGFILE   
echo "bohc" $bohc | tee -a $LOGFILE   
echo "waserrc" $waserrc | tee -a $LOGFILE   
echo $tuttok $openerr $notconvnormal $incc $diisfail $okbuttst $bohc $waserrc | tee -a $LOGFILE   
echo $tuttok $openerr $notconvnormal $incc $diisfail $okbuttst $bohc $waserrc | awk '{print $1+$2+$3+$4+$5+$6+$7+$8}'  | tee -a $LOGFILE 
