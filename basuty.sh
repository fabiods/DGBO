#!/bin/bash
#set -u
#set -x
function xnext() {
    val=$1
    fff=$2
if [ "$fff" == "%2.0E" ]; then
    dec=1
elif [ "$fff" == "%3.1E" ]; then
    dec=0.1
elif [ "$fff" == "%4.2E" ]; then
    dec=0.01
elif [ "$fff" == "%5.3E" ]; then
    dec=0.001
fi
#    echo $val
    ordg=`echo $val | awk -F E '{ print "1E"$2} '`
#    echo $ordg
    echo $val $ordg | awk -v fmt=$fff -v d=$dec '{printf fmt,($1/($2*d)+1)*($2*d)}'
}

function xprec() {
    val=$1
    fff=$2
if [ "$fff" == "%2.0E" ]; then
    dec=1
elif [ "$fff" == "%3.1E" ]; then
    dec=0.1
elif [ "$fff" == "%4.2E" ]; then
    dec=0.01
elif [ "$fff" == "%5.3E" ]; then
    dec=0.001
fi
#    echo $val
    ordg=`echo $val | awk -F E '{if ( $1 != 1 ) {print "1E"$2} else {printf "%s%+2.2d\n","1E",($2-1)} }'`
#    echo $ordg
    echo $val $ordg | awk -v fmt=$fff -v d=$dec '{printf fmt,($1/($2*d)-1)*($2*d)}'
}


function eigratio() {
  echo "eigratio{",$1 >> $LOGFILE
  input=$1
  if [ ! -e $input.eigs.rmax ]; then 
   runcry23OMP 4 inputhfeigs &>> $LOGFILE
   cp inputhfeigs.out $input.eigs
#	/home/atom/ATOMSOFT/CRYSTAL/NEWOMP2/bin/Linux-ifort_i64_omp/dev/crystalOMP < inputhfeigs.d12 > $input.eigs
   ball=`grep "ALL G-VECTORS USED" $input.eigs | wc -l`
   if [ "$ball" -ne "1" ]; then 
    nk=`grep "NUMBER OF K POINTS IN THE IBZ" $input.eigs | awk '{print $13}'`
    echo 'nk' $nk >> $LOGFILE
    rmax=0.0
    nk=1
    for ((k = 0 ; k < $nk ; k++ ))
    do
     sr=`echo $k | awk  '{printf "%d(",$1+1}'`
#    echo $sr >> $LOGFILE
#     grep -A 10 $sr  $input.eigs  |  awk -v RS= 'NR==1' | tail -n +2 | awk '{print $1,"\n",$NF}'    > tmpee
     grep -A 10 $sr  $input.eigs  |  awk -v RS= 'NR==1' | tail -n +2 > tmpee
     awk '{ for (i=1;i<=NF; i++) printf("%s\n",$i); }' tmpee | sort -g  > tmpb
     amin=`head -n 1 tmpb | awk '{printf "%30.20f", $1}'`
     amax=`tail -n 1 tmpb`      	
#    grep -A 10 "S(K) EIGENV - K =   1( 0 0 0)" $input.eigs |  awk -v RS= 'NR==1' | tail -n +2 | awk '{print $1,"\n",$NF}'    > tmp
#    amin=`head -n 1 tmp | awk '{printf "%30.20f", $1}'`
#    amax=`tail -n 1 tmp `
     echo "$sr amin amax" $amin $amax  >> $LOGFILE
     xmin=`echo "$amin < 0" | bc -l`
     echo "xmin" $xmin >> $LOGFILE 
     if [ "$xmin" == "1" ]; then
       amin=`echo $amin | awk '{printf "%30.20f", -$1}'`
     fi
#    echo "amin" $amin >> $LOGFILE
     ratio=`echo $amin $amax | awk '{printf "%40.10f",$2/$1}'`
     echo "amin ratio rmax " $amin $ratio $rmax  >> $LOGFILE
        
     rmaxis=`echo "$ratio > $rmax" | bc -l`
     echo "rmaxis" $rmaxis >> $LOGFILE
     if [ "$k" == "0" ]; then
	rmax0=$ratio
     fi	
     if [ "$rmaxis" == "1" ]; then
	rmax=$ratio
	echo $k $rmax >> $input.eigs.rmax
	echo $k $rmax >> $LOGFILE
     fi	
     if [ "$rmax" == "0.0" ]; then
      echo "$rmax is 0"
       exit -1
     fi  
    done
   else
    echo "ALLG in eigs" >> $LOGFILE
   fi
  else
   rmax0=`head -n 1 $input.eigs.rmax | awk '{print $2}'`
   rmax=`tail -n 1 $input.eigs.rmax | awk '{print $2}'`
   rmax=$rmax0
   ratio=$rmax
   echo "rmax found: rmax0 rmax" $rmax0 $rmax >> $LOGFILE
  fi
  if [ "$silent" == "no" ]; then
	echo "RMAX RMAX0" $rmax $rmax0 | tee -a $LOGFILE
  fi	
  echo "}eigratio" >> $LOGFILE 
}

function getenefromout {
    inp=$1
    ttol=$2
    tsilent=$3
    removefile=$4
#---output------------------
#    ene
#    waserr
    #-------------------
    echo "getenefromout{" $1 $2 $3 $4 >> $LOGFILE
    blin=`grep "Basis set Linear dependence" $inp | wc -l`
    ball=`grep "ALL G-VECTORS USED"          $inp | wc -l`
    bila=`grep "INCREASE ILASIZE"            $inp | wc -l`
    chklla=""
    chktst=""
    chdetot=""
    chkdiis=""
    lla="1"
    llaa="1"
    tst="1"
    diis="1"
    if [ "$blin" -eq "1" ] || [ "$ball" -eq "1" ] || [ "$bila" -eq "1" ] ; then
	 if [ "$tsilent" == "no" ];  then
	     echo "LIN DEP or ALLG or ILA"
	 else
	      echo "LIN DEP or ALLG or ILA" >>$LOGFILE
	 fi    
         ene="NACRASH"
	 waserr="no"
    else
 	zerohfene=`grep -A 1 "ZNUC  SCFIT" $inp | tail -n 1 | awk '{print $3}'`
#	 tma=`grep "SCF ENDED - TOO MANY CYCLES"   $inp | wc -l`
	 isdetot=`grep "TOTAL ENERGY(HF)"            $inp | wc -l | awk '{print $1}'`
	 #	 echo $tma , $isdetot , $detot
	 echo "isdetot" $isdetot >> $LOGFILE
	 if [ "$isdetot" -eq "0" ]; then
            waserr="yes"
	    ene="NAERR"
	    chdetot=-1
	 else     
	     detot=`grep "TOTAL ENERGY(HF)"            $inp | awk -F DE '{print $2}' | awk '{printf "%30.10f",$1}'`
	     detota=`echo "sqrt($detot*$detot)" | bc -l`
	     # 8 perche ci sono problemi all ultimo ciclo 
	    chdetot=`echo "sqrt($detot*$detot) <= 99*$ttol" | bc -l`
	    chdetotv=`echo "sqrt($detot*$detot) <= $ttol" | bc -l`
	    chdetotf=`echo "sqrt($detot*$detot) <= 999*$ttol" | bc -l`    
	    tma=`grep "SCF ENDED - TOO MANY CYCLES"   $inp | wc -l`             
	    echo "tma detot chdetot chdetotv" $tma $detota $chdetot $chdetotv >> $LOGFILE 

  	    if [ "$chdetot" -eq "0" ]; then   
#	 if [ "$tma" -eq "1" ]; then
               if [ "$tsilent" == "no" ]; then
		 echo "NOT CONV"
	       else
		  echo "NOT CONV" >>$LOGFILE
	       fi	 
               ene="NANOTCONV"
#	     echo "NAAAAAAAAAA"
	       waserr="no"

            else
		
# 1          2          3           4            5   	     
#TOTAL ENERGY(HF)(AU)(  26) -7.6128265114468E+00 DE-2.6E-08 tst 5.4E-13 PX 6.8E-07
              ene=`grep "TOTAL ENERGY(HF)"   $inp | awk '{print $4}'`
#	  detot=`grep "TOTAL ENERGY(HF)" $inp | awk -F DE '{print $2}' | awk '{printf "%30.10f",$1}'`     
              if [ "$ene" != "" ]; then  
#		  tst=`grep "TOTAL ENERGY(HF)" $input | awk '{printf "%30.10f",$8}'`
	       tst=`grep "TOTAL ENERGY(HF)" $inp | awk -F tst '{print $2}' | awk '{printf "%30.10f",$1}'`
	       chktst=`echo "$tst <= 8*$ttol" | bc -l`
	       echo "checktest" $tst $chktst >> $LOGFILE
              else
		 chktst=-1 
		 waserr="yes" 
	      fi
	      # ---------------last but one cycle-----------
	      lla=`grep DETOT              $inp | tail -n 2 | head -n 1 | awk '{printf "%30.10f",$6}'`
	      llaa=`echo "sqrt($lla*$lla)" | bc -l` 
	      # controllo ultimo detot, perche la convergenza e' sulla penultima
	      if [ "$lla" != "" ]; then 
	       chklla=`echo "sqrt($lla*$lla) <= $ttol" | bc -l`
	       echo "checklast" $lla $chklla >> $LOGFILE
              else
		  chklla=-1
		  waserr="yes"
	      fi
 #                        1          0          -1
 #	      1                                 crash
 #	      0                     notconv     crash
 # 	      -1         crash      crash       crash                        
 #
              #===============diis==============	      
              diis=`grep "DIIS TEST" $inp | tail -n 1 | awk '{printf "%30.15f",$3}'`
              chkdiis=`echo "sqrt($diis*$diis) <= 9*$ttol" | bc -l`
              echo "diis" $diis $chkdiis >> $LOGFILE
	      
	      if  [ "$chktst" -eq "-1" ] ||  [ "$chklla" -eq "-1" ] ; then
	        waserr="yes"
	        if [ "$removefile" == "yes" ]; then
		   rm $input
	        fi
	      elif [ "$chklla" -eq "1" ]; then
#	      elif [ "$chktst" -eq "1" ] ||  [ "$chklla" -eq "1" ] ; then
	        if [ "$chkdiis" -eq "0" ]; then
		   if [ "$tsilent" == "no" ]; then 
		       echo "DIIS FAIL"
		   else
		       echo "DIIS FAIL" >> $LOGFILE
		   fi
		   ene="NADIIS"
		   waserr="no"
	        else   
#                  if [ "$tsilent" == "no" ]; then
#		   echo "ENERGY" $ene
#	          else
#		   echo "ENERGY" $ene >> $LOGFILE
#	          fi
		
	          if [ "$ene" != "" ]; then
	           waserr="no"
	          else
	           waserr="yes"
	           if [ "$removefile" == "yes" ]; then
		     rm $input
		   fi    
	          fi #ene
	        fi #diis	
	      else
	   # calculation done but it is NOT CONVERGED  (checktest=0 and chklla=0)  
#	       lla=`grep DETOT $input | tail -n 2 | head -n 1 | awk '{printf "%30.10f",$6}'`
#	       llb=`grep DETOT $input | tail -n 1             | awk '{printf "%30.10f",$6}'`
	       
	        if [ "$tsilent" == "no" ]; then
		   echo "NO TEST passed"
	        else
		   echo "NO TEST passed" >> $LOGFILE
	        fi	   
	        ene="NANOTCONV"
	        waserr="no"
	      fi # maincheck
	    fi #chdetot    
         fi # isdetot
	     
    fi  # bline
    echo "waserr" $waserr >> $LOGFILE
    echo "ene" $ene >> $LOGFILE 
    echo "}getenefromout" >> $LOGFILE
}

function runcry() {
    input=$1
    if [ "$silent" == "no" ]; then
	echo "Running in " $input
    else
	echo "runcry{ Running in " $input >> $LOGFILE
    fi	
#    export OMP_NUM_THREADS=20
    sed -i '/GUESSP/d'  inputhf.d12
    sed -i '/EXCHGENE/d' inputhf.d12
    waserr="yes"
    cc=0
    chdetot=1
    chklla=1
    while [ "$waserr" == "yes" ] && [ "$cc" -lt "5" ]; do
	cc=$((cc+1))
# cc=1 is the first check, can be wrong ouutput	
	if [ ! -s "$input" ]; then
	    echo "running crystal" >> $LOGFILE
#	    if [ "$chdetot" -eq "0" ] && [ "$chklla" -eq "0" ]; then
#	      sed -i '/HISTDIIS/{ n; s/5/30/g }' inputhf.d12
#	      sed -i 's/DIIS/SLOSHING/g' inputhf.d12
#	    fi  
#	    runPcry23 14 inputhf  &>> $LOGFILE
	    #	    runcry23 inputhf &>> $LOGFILE
	    runcry23OMP 16 inputhf &>> $LOGFILE
	    #	 /home/atom/ATOMSOFT/CRYSTAL/NEWOMP2/bin/Linux-ifort_i64_omp/dev/crystalOMP < inputhf.d12 > $input
	    cp inputhf.out $input
	    # cp fort.9 fort.20.$input
	    cp inputhf.f9 fort.20.$input
        fi
         getenefromout $input $tolb $silent "yes"
	
         echo "waserr" $waserr >> $LOGFILE
     done
    echo "ENERGY(runcry) " $ene >> $LOGFILE
#    echo "qui" $input.ene  >> $LOGFILE
#    echo " " $ene $enevera > $input.ene 
    echo "}runcry" >> $LOGFILE
}   

function runcrycond(){
    #    set -x
    echo "runcrycond{" $1 >> $LOGFILE
    input=$1
    errxbas=$2
    echo "errxbas" $errxbas >> $LOGFILE
    if [ "$errxbas" -eq "0" ]; then
      if [ ! -e $input.eigs.rmax ]; then   
          sed  s/EXCHGENE/EIGS/g inputhf.d12 > inputhfeigs.d12
          sed -i '/GUESSP/d'  inputhfeigs.d12
      fi
      eigratio $input
      toom=`echo "$rmax > 10000" | bc -l`
      if [ "$toom" == 1 ]; then
	ene="NARMAX"
      else	
	runcry $input
      fi	
#rmax
    #    gamma=0.000005
#rmax0    
#    gamma=0.001
#    gamma=0.000000
    else
	ene="NAPROG"
	rmax=10000
	rmax0=10000
    fi

    enevera=$ene
    
    if [[ $ene != NA* ]]; then
	echo "rmax" $rmax >> $LOGFILE
        enef=`echo $ene | awk '{printf "%30.10f",$1}'`	
	cond=`echo "$enef + $gamma*l($rmax)"  | bc -l`
	if [ "$silent" == "no" ]; then
	    echo "COND  " $cond
	fi    
	conddiff=`echo $enef $cond | awk '{print $2-$1}'`
	ene=$cond
        echo "COND " $cond >> $LOGFILE
	echo "conddiff"  $conddiff >> $LOGFILE
	echo $ene $enef $conddiff $dstr >> $LISTENE
	echo "rmax rmax0" $rmax $rmax0 $ene $enef $str >> notconv.dat
    else
	echo "rmax rmax0" $rmax $rmax0 $ene $ene $str >> notconv.dat
    fi
    if [ -e "ENEREFZERO.dat" ]; then
	enerefzero=`awk '{printf "%30.10f",$1}' ENEREFZERO.dat`
    else
	enerefzero=0
    fi
    echo "enerefzero" $enerefzero >> $LOGFILE
    if [[ $ene == NA* ]]; then
	echo "ENERGY",$rmax,$ene >> $LOGFILE
	ene=`echo "l($rmax) + $enerefzero" |  bc -l`
	echo "ENERGY",$rmax,$ene >> $LOGFILE
    fi
    echo "qui" $input.ene  >> $LOGFILE
    echo " " $ene $enevera > $input.ene 
    echo "}runcrycond" >> $LOGFILE
}

function sedinput() {
    
    fname=$1
    ii=$2
    pn=$3
    echo "sedinput{" $fname $ii $pn $GMF >> $LOGFILE
    j=0
    str=""
    dstr=""
    xvaln="0"
    cat $fname >> $LOGFILE
    while read -r line; do
	pnname=""
	name=`echo $line  | awk '{print $1}'` 	
     if [ "$j" == "$ii" ]; then 
	val=`echo $line  | awk '{print $2}'`
	if [ "$pn" == "1" ] ; then 
	 valn=`echo $val | awk -v p=$perc -v fmt=$GMF  '{printf fmt, $1*(1+p)}'`   
	 pnname='pos'
	 xname=$name
	 xvaln=$valn
        else
         valn=`echo $val | awk -v p=$perc -v fmt=$GMF '{printf fmt, $1*(1-p)}'`
         pnname='neg'
	 xname=$name
	 xvaln=$valn
	fi 
     else	
         valn=`echo $line  | awk -v fmt=$GMF '{printf fmt, $2}'`
     fi
     if [ "$str" != "" ]; then 
	 str=$str"_"$name$valn
	 dstr=$dstr" "$valn
     else
	 str=$name$valn
	 dstr=$valn
     fi	
       
     echo " " $pnname $name $valn  >> $LOGFILE
     sed -i s/$name/$valn/g inputhf.d12
     j=$((j + 1))

    done < $fname
    echo "  str" $str >> $LOGFILE
    echo " dstr" $dstr >> $LOGFILE
    echo "  xvaln" $xvaln >> $LOGFILE
    echo "}sedinput" >> $LOGFILE
    }

