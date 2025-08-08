#!/bin/bash
set -u
#set -x
source ~/DGBO/basuty.sh

# test at ~/optpy/li6/f1/INC/lowoptquesto

function sedinputx() {
    fname=$1
    ii=$2
    pn=$3
    echo "sedinputx{" $fname $ii $pn >> $LOGFILE
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
	 echo "val" $val >> $LOGFILE
	if [ "$pn" == "1" ] ; then
	 valn=`xnext $val $GMF`   
#	 valn=`echo $val | awk -v p=$perc -v fmt=$GMF  '{printf fmt, $1*(1+p)}'`   
	 pnname='pos'
	 xname=$name
	 xvaln=$valn
        else
	 valn=`xprec $val $GMF`
#         valn=`echo $val | awk -v p=$perc -v fmt=$GMF '{printf fmt, $1*(1-p)}'`
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
    echo "}sedinputx" >> $LOGFILE
    }


function gradient() {
#    set -x
# input  sedfile   
    fname=$1
    ezero=$2
#  
 nbas=`wc -l $fname |awk '{print $1}'`
 store=gradient.$fname
# if [ ! -e $store ]; then 
 rm $store
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

 

    cp inputhf.d12.par inputhf.d12
      
    sedinputx $fname $i $pn
    echo "" >> $LOGFILE  
    echo ">>>> pn= $pn i=$i $xvaln" >>  $LOGFILE
    echo " ~/DGBO/checkbr.x 1.4 $dstr > br.out" >>$LOGFILE
    
    ~/DGBO/checkbr.x 1.4 $dstr > br.out
    cat br.out >> $LOGFILE
    nxtot=`grep ierr br.out | awk '{print $2}'`
#    echo " " $str
#    runcry  out.$pnname.$xname
    
    runcrycond  out.$str $nxtot

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
	posup=`echo "$ene>$enezero+$tolb" | bc -l`
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
         posdn=`echo "$ene>$enezero+$tolb" | bc -l`
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
	     echo "minimum"  >> $LOGFILE
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
	hess=`echo $enepos $eneneg $denright $denleft $enezero | awk '{print ($1*$4+$2*$3-$5*($3+$4))/(0.5*($3+$4)*$3*$4)}'` 
	echo 'hess',$hess >>$LOGFILE
     finalderright=`echo $derright $denright | awk '{printf "%15.10e", $1/$2}' `
     finalderleft=`echo  $derleft  $denleft  | awk '{printf "%15.10e", $1/$2}' `   
     finalder=`echo $dene $dden | awk '{printf "%15.10e", $1/$2}' `
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
}


LOGFILE='basdergmf.log'
rm $LOGFILE
echo "---- bas der gmf ---"  | tee -a $LOGFILE
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
LISTENE='allene.dat'
#rm $LISTENE
gamma=0
silent="yes"
told=`grep -A 1 "TOLDEE" inputhf.d12.par | tail -n 1 `
tol=`echo $told | awk '{print 10**(-$1)}'`
tolb=`echo $tol | awk '{printf "%15.10f",$1}'`

echo 'tol', $told $tol $tolb >> $LOGFILE
#cat basrunsed.dat >>$LOGFILE
#------------------------------------------------------
cp inputhf.d12.par inputhf.d12
sedinputx basrunsed.dat -1 -1

echo " ~/DGBO/checkbr.x 1.4 $dstr > br.out" >>$LOGFILE   
~/DGBO/checkbr.x 1.4 $dstr > br.out
#cat br.out >>$LOGFILE
nxtot=`grep ierr br.out | awk '{print $2}'`
echo "nxtot" $nxtot >>$LOGFILE
#set -x
runcrycond out.$str $nxtot
#exit
enezero=$ene

if [[ $enevera == NA* ]]; then
       echo "ERROR: initial point is $enezero"
else       
 echo "enezero" $ene | tee -a $LOGFILE 
 #set -x
 
 cp basrunsed.dat   basrunsed.dat.g

 gradient basrunsed.dat $enezero
 
 mv basrunsed.dat.g basrunsed.dat
fi
    
