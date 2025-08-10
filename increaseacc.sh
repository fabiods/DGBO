#!/bin/bash
#set -x
# input file:
# basrun.allene.dat
# sedfile.dat

# recreated basrun.allene.dat.uniq and nc.dat
# allene.dat is from basdergmf
cat basrun.allene.dat allene.dat > tmpx
sort -k 2 -r -g  tmpx  | uniq > basrun.allene.dat.uniq
awk '{print NF-3}' basrun.allene.dat.uniq | head -n 1 > nc.dat

newfmt=$1

mkdir  INC
cp ENEREFZERO.dat INC
~/DGBO/xdiff.x < basrun.allene.dat.uniq > xdiff.out
gran=`grep granularity xdiff.out | awk '{print $2}'`
echo "gran" $gran

fmto=$GMF"\n"
grep ox xdiff.out | awk -v fmt=$fmto '{printf fmt, $2}' > ox.list
awk -v gg=$gran '{print $1*gg}' ox.list > ox.listg



for kk in {1..2}; do
    
tail -n $kk basrun.allene.dat.uniq | head -n 1  | awk '{ for (i=4; i<=NF; i++) printf("%s\n",$i); }' > INC/sedfile.dat.tmp.$kk
echo 'selected minima : ' $kk
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
rm basrun.allene.dat
rm notconv.dat
rm basrun.log
rm allene.dat
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
