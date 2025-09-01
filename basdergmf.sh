#!/bin/bash
set -u
#set -x
source ~/DGBO/basuty.sh

# test at ~/optpy/li6/f1/INC/lowoptquesto

function gradientpara() {
#    set -x
# input: sedfile, ezero, inputhf, nprocs    
    fname=$1
    ezero=$2
    inputhf=$3
    nprocs=$4
#  
    nbas=`wc -l $fname |awk '{print $1}'`
 echo  | tee -a $LOGFILE       
 echo "gradientpara{ " $fname $ezero $inputhf $nprocs | tee -a $LOGFILE
 ck=0
 tosim=0
 for ((i = 0 ; i < $nbas ; i++ ))
 do
  for pn in {1..2}
  do
      ck=$((ck+1))
      echo $i $pn ":" $ck | tee -a $LOGFILE  
    cp inputhf.d12.par $inputhf.$ck".d12"
      
    sedinputx $fname $i $pn $inputhf.$ck bmax.dat
    if [ -e out.$str ]; then
	echo out.$str found  | tee -a $LOGFILE  
    else
	checktoberun $BPROG "$dstr" out.$str $inputhf.$ck $fname
	echo "toberun $toberun"  | tee -a $LOGFILE  
        if [ "$toberun" == "yes" ]; then	
	 tosim=$((tosim+1))
	 pp=`echo $ck | awk '{printf "P%d",$1}'`
	 echo "tosim" $tosim $pp | tee -a $LOGFILE  
	 if [ "$tosim" -le 3 ]; then
	     echo "~/DGBO/basrun.sh $pp $dstr >& runcry.$pp &   " | tee -a $LOGFILE  
	           ~/DGBO/basrun.sh $pp $dstr >& runcry.$pp &
	 fi
	 if [ "$tosim" -eq 3 ]; then
        echo "wait 3 run" | tee -a $LOGFILE  
	    wait
	    tosim=0
	 fi
	fi 
    fi
    
#    ~/DGBO/checkbr.x 1.4 $dstr > br.out
#    cat br.out >> $LOGFILE
#    nxtot=`grep ierr br.out | awk '{print $2}'`
#    if [ ! -e ~/DGBO/basrun.sh $str
#    runcrycond  out.$str $nxtot $inputhf.$ck 

  done

 done
 echo "final wait" | tee -a $LOGFILE  
 wait
 for ((i = 1 ; i <= $ck ; i++ ))
 do
 rm $inputhf.$i.*
 done
 echo "}GRADIENT PARA " >>$LOGFILE
}


function gradient() {
#    set -x
# input: sedfile, ezero, inputhf    
    fname=$1
    ezero=$2
    inputhf=$3
    #
   
 nbas=`wc -l $fname |awk '{print $1}'`
 store=gradient.$fname
# if [ ! -e $store ]; then 
 rm $store
 echo >>$LOGFILE    
 echo "GRADIENT{" >>$LOGFILE
 echo "gradient" $fname $nbas  | tee -a $LOGFILE
 ismin=0
 isnc=0
 for ((i = 0 ; i < $nbas ; i++ ))
 do
  ddone=0
  ck=0
  dene=0
  echo | tee -a $LOGFILE 
  while [ "$ddone" == "0" ] && [ "$ck" -lt 4 ]
  do
  ck=$((ck+1))    
#  dertwo=`echo $enezero| awk '{print $1*}'`     
  for pn in {1..2}
  do

 

    cp inputhf.d12.par $inputhf".d12"
      
    sedinputx $fname $i $pn $inputhf bmax.dat
    echo "" >> $LOGFILE  
    echo ">>>> pn= $pn i=$i $xvaln" >>  $LOGFILE
    echo " ~/DGBO/checkbr.x basrunsed.dat $BPROG $dstr > br.out" >>$LOGFILE
    
    ~/DGBO/checkbr.x basrunsed.dat $BPROG $dstr > br.out
    cat br.out >> $LOGFILE
    nxtot=`grep ierr br.out | awk '{print $2}'`
#    echo " " $str
#    runcry  out.$pnname.$xname
    
    runcrycond  out.$str $nxtot $inputhf

#   MAIN OUT ENEDIFF
    echo $ene $enezero $i $xvaln $enevera | awk '{print " ENEDIFF",$1-$2,$3,$4,$5}' | tee -a $LOGFILE 
    
    if [ "$pn" == "1" ]; then
	# positive
        der=$ene
	den=$xvaln
	enepos=$ene
	denpos=$xvaln
	derright=`echo $ene $enezero  | awk '{printf "%15.10e",$1-$2}'`   
	denright=`echo $xvaln $val     | awk '{printf "%4.3e",$1-$2}'`
	echo "xx" $xvaln $val >> $LOGFILE
	posup=`echo "$ene>$enezero-$tolb" | bc -l`
	ncup=0
	if [[ $enevera == NA* ]]; then
                if [ "$enevera" != "NAPROG" ]; then  
	         ncup=1
                fi
	fi    
#	ncup=`echo "$ene> 0" | bc -l`
    else
	# negative
	if [ "$ene" != "NA" ]; then
         posdn=`echo "$ene>$enezero-$tolb" | bc -l`
	 dene=`echo $der $ene | awk '{printf "%15.10e",$1-$2}'`
	 dden=`echo $den $xvaln | awk '{printf "%4.3e",$1-$2}'`
	 eneneg=$ene
	 denneg=$xvaln
	 derleft=`echo $enezero  $ene | awk '{printf "%15.10e",$1-$2}'`
	 denleft=`echo $val  $xvaln   | awk '{printf "%4.3e",$1-$2}'`
	 ncdn=0
	 if [[ $enevera == NA* ]]; then
               if [ "$enevera" != "NAPROG" ]; then  
	       ncdn=1
               fi
         fi	     
#	 ncdn=`echo "$ene> 0" | bc -l` 
	 echo "xx" $xvaln $val >> $LOGFILE
	 echo "nc" $ncup $ncdn >> $LOGFILE
	 echo "DEBUG:" $dene "den"=$dden $i  | tee -a $LOGFILE
	 if [ "$posup" == "1" ] && [ "$posdn" == "1" ]; then
	     echo "is min"  | tee -a $LOGFILE
             ismin=$((ismin+1))
	 fi
	 if [ "$ncup" == "1" ] && [ "$ncdn" == "1" ]; then
	     echo "instability"  >> $LOGFILE
	     isnc=$((isnc+1))
	 fi    
	else
	 # no derivative   
	    dene=1
	    dden=`echo $den $xvaln | awk '{printf "%4.3e",$1-$2}'`
	fi    
    fi
#    echo $dene
    if [ "$dene" != "0" ]; then
	#           1      2     3         4
	echo $enepos $eneneg $denright $denleft $enezero  >> $LOGFILE
	hess=`echo $enepos $eneneg $denright $denleft $enezero | awk '{print ($1*$4+$2*$3-$5*($3+$4))/(0.5*($3+$4)*($3+0.0000001)*($4+0.0000001))}'` 
	echo 'hess',$hess >>$LOGFILE
     finalderright=`echo $derright $denright | awk '{printf "%15.10e", $1/($2+0.0000001)}' `
     finalderleft=`echo  $derleft  $denleft  | awk '{printf "%15.10e", $1/($2+0.0000001)}' `   
     finalder=`echo $dene $dden | awk '{printf "%15.10e", $1/($2+0.0000001)}' `
     echo "der $i" $finalder  $finalderleft  $finalderright >>  $LOGFILE
     echo "der $i" $finalder  $finalderleft  $finalderright >> $store
    fi
  done
  ddone="yes"
  done
#  exit
done
# else
#     echo $store "alreay exists"
# fi
 echo "gradient is:" | tee -a $LOGFILE
     cat $store  | tee -a $LOGFILE

     echo "notconv" $isnc    $nbas | tee -a $LOGFILE
     echo "minimum" $ismin  $nbas  | tee -a $LOGFILE
 echo "}GRADIENT"     >> $LOGFILE
}


#-------------------MAIN-------------

if [ -e "gamma.info" ]; then
   gamma=`cat gamma.info`
else
   gamma=0    
fi
LOGFILE="basdergmf.$gamma.log"

# dont delete
#rm $LOGFILE

echo "gamma" $gamma  >> $LOGFILE
   
echo "---- bas der gmf ---"  | tee -a $LOGFILE
numpar=$#
if [ ${GMF:-"undef"} == "undef" ]; then
    echo "GMF NOT DEFINED" | tee -a $LOGFILE 
    GMF="%5.3E"
fi
echo "GMF" $GMF | tee -a $LOGFILE 

if [ ! -e inputhf.d12.par ];  then
    echo "inputhf.d12.par not found"
    exit
fi    
#nn=`xnext $1 $GMF`
#echo "next" $nn

#pp=`xprec $1 $GMF`
#echo "prec" $pp
#exit
if [ "$numpar" == "0" ]; then
    echo "parameter not specified" | tee -a $LOGFILE 
    echo "using basrunsed.dat" | tee -a $LOGFILE 
    if [ ! -e  'basrunsed.dat' ]; then
 	 echo "cannot found basrunsed.dat"
	 exit
    fi
    cat basrunsed.dat
    sss="%s "$GMF"\n" 
    awk -v fmt="$sss" '{printf fmt,$1,$2}' basrunsed.dat >tmt
    mv basrunsed.dat basrunsed.dat.old
    mv tmt basrunsed.dat
#    cat basrunsed.dat | tee -a $LOGFILE 
else    
 rm tmpsed >& /dev/null
 for var in "$@"
 do
    echo "$var" | awk -v fmt=$GMF"\n" '{printf fmt,$1}'>> tmpsed
 done
# tmpsed cannot be WITHOUT GMF format


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
fi

echo "final basrunsed.dat" | tee -a $LOGFILE
cat basrunsed.dat | tee -a $LOGFILE 
#---------------required global------------------
LISTENE="allene.$gamma.dat"
#rm $LISTENE

if [ -e "maxrmax.info" ]; then
   maxrmax=`cat maxrmax.info`
else
   maxrmax=10000    
fi
   echo "maxrmax" $maxrmax >> $LOGFILE


silent="yes"
told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%15.10f",$1}'`

echo 'tol', $told $tol $tolb >> $LOGFILE
#cat basrunsed.dat >>$LOGFILE

export BPROG="1.4"
#-------------------run the starting point -----------------------------------
myinputhf="inputhf"

cp inputhf.d12.par $myinputhf".d12"
sedinputx basrunsed.dat -1 -1 $myinputhf bmax.dat

echo " ~/DGBO/checkbr.x basrunsed.dat $BPROG $dstr > br.out" >>$LOGFILE   
       ~/DGBO/checkbr.x basrunsed.dat $BPROG $dstr > br.out
#cat br.out >>$LOGFILE
nxtot=`grep ierr br.out | awk '{print $2}'`
echo "nxtot" $nxtot >>$LOGFILE

#set -x
runcrycond out.$str $nxtot $myinputhf
#exit


enezero=$ene

if [[ $enevera == NA* ]]; then
       echo "ERROR: initial point is $enezero"
else       
 echo "enezero" $ene | tee -a $LOGFILE 
 #set -x
 
 cp basrunsed.dat   basrunsed.dat.g

# this can be parallelized:
 gradientpara basrunsed.dat $enezero $myinputhf   1
# exit
 gradient basrunsed.dat $enezero $myinputhf
 
 mv basrunsed.dat.g basrunsed.dat
fi
