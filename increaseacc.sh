#!/bin/bash
#set -x
# input file:
# basrun.allene.dat
# sedfile.dat

# recreated basrun.allene.dat.uniq and nc.dat
# allene.dat is from basdergmf

if [ -e "gamma.info" ]; then
   gamma=`cat gamma.info`
   else
   gamma=0    
fi

cat basrun.allene.$gamma.dat allene.$gamma.dat > tmpx
sort -k 2 -r -g  tmpx  | uniq > basrun.allene.$gamma.uniq.dat
awk '{print NF-3}' basrun.allene.$gamma.uniq.dat | head -n 1 > nc.dat

newfmt=$1

mkdir  INC
cp ENEREFZERO.dat INC
cp gamma.info INC  
cp maxrmax.info INC 
~/DGBO/xdiff.x < basrun.allene.$gamma.uniq.dat > xdiff.out
gran=`grep granularity xdiff.out | awk '{print $2}'`
echo "gran" $gran

fmto=$GMF"\n"
grep ox xdiff.out | awk -v fmt=$fmto '{printf fmt, $2}' > ox.list
awk -v gg=$gran '{print $1*gg}' ox.list > ox.listg



for kk in {1..2}; do
    
tail -n $kk basrun.allene.$gamma.uniq.dat | head -n 1  | awk '{ for (i=4; i<=NF; i++) printf("%s\n",$i); }' > INC/sedfile.dat.tmp.$kk
echo
echo
echo 'selected minima : ' $kk
echo
echo
cat  INC/sedfile.dat.tmp.$kk

paste sedfile.dat INC/sedfile.dat.tmp.$kk | awk '{print $1,$3}' > INC/sedfile.dat

export GMF=$newfmt 

cp inputhf.d12.par INC

#---run bas der flow----#
cd INC
cp sedfile.dat basrunsed.dat
~/DGBO/basderfol.sh | tee basderfol.out
xxx=`tail -n 1 basderfol.out`
echo "res:" $xxx
cd ..


paste INC/sedfile.dat.tmp.$kk | awk '{print $1,$1}' > bounds_inc.dat

~/DGBO/boundsinc.sh bounds_inc.dat   > bounds_inc1.dat
~/DGBO/boundsinc.sh bounds_inc1.dat  > bounds_inc2.dat
~/DGBO/boundsinc.sh bounds_inc2.dat  > bounds_inc3.dat
~/DGBO/boundsinc.sh bounds_inc3.dat  > bounds_inc4.dat
~/DGBO/boundsinc.sh bounds_inc4.dat  > INC/bounds.dat  

#paste INC/sedfile.dat.tmp.$kk ox.listg | awk '{print $1-$2/2,$1+$2/2}' >INC/bounds.dat
#exit
cd INC
if [ "$kk" == "1" ]; then
rm basrun.allene.$gamma.dat
rm notconv.$gamma.dat
rm basrun.$gamma.log
rm allene.$gamma.dat
fi
#pwd
#python -u ~/opt3.py nd

#pwd
#python -u ~/opt3.py pow

#pwd
#python -u ~/opt3.py boby

pwd
python -u ~/DGBO/opt5zoo.py

cd ..

done
echo "end loop over minima"
