#!/bin/bash
function subset () {

echo "===maxcycle==="
grep -A 1 MAXCYCLE inputhf.d12.* | grep -v "~"

nc=`grep -A 1 MAXCYCLE inputhf.d12.par | grep -v MAXCYCLE`
echo $nc
echo "================"
nr=`cat maxrmax.info`
echo $nr

if [ ! -e "checkallout.out" ]; then
    ~/DGBO/checkallout.sh  >  checkallout.out
fi

echo "==incmax====="  
ninc=`grep inccyc checkallout.out | awk '{print $2}'`
echo $ninc

~/DGBO/doincmax.sh | tee coco.out
nnor=`grep "out" coco.out | wc -l`
echo $nnor
echo "=========="
echo "===nsims==="
~/DGBO/dodgbostat $gamma >   dodgbostat.$gamma.out
# two values
nn=`grep new dodgbostat.$gamma.out | awk '{print $4}'`
ntot=`head -n 1 dodgbostat.$gamma.out | awk '{print $5}'`
nok=`grep "total call ok"   dodgbostat.$gamma.out | awk '{print $5}'` 
echo $nn $ntot $nok
echo "=========="
if [ "1" == "0" ]; then
echo "-----------------------------------"
cd INC
#~/DGBO/runincacc
~/DGBO/checkallout.sh
~/DGBO/dodgbostat 0.001
~/DGBO/dodgbostat 0.002

cd INC3
~/DGBO/checkallout.sh
~/DGBO/dodgbostat 0.001
~/DGBO/dodgbostat 0.002
cd ../../
fi

echo $nc $nr "|" $ntot $nok $nn "|" $ninc $nnor 


}

gamma=$1

pwd
# ~/DGBO/rundgbo
subset


# ~/DGBO/runincacc
cd INC
pwd
subset
cd ..


#cd INC
#~/DGBO/runinc3 $gamma
#cd ..
cd INC/INC3
pwd
subset
cd ../../
