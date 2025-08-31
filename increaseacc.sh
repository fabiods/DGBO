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
echo "gamma" $gamma
cat basrun.allene.$gamma.dat allene.$gamma.dat > tmpx
sort -k 1 -r -g  tmpx  | uniq > basrun.allene.$gamma.uniq.dat
rm tmpx
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



for kk in {1..3}; do
# 1 abs min
# 2 abs min
# 3 min basrun

 if [ "$kk" == "3" ]; then
   sort -k 1 -r -g   basrun.allene.$gamma.dat | uniq > tmpx
   tail -n 1 tmpx  | awk '{ for (i=4; i<=NF; i++) printf("%s\n",$i); }' > INC/sedfile.dat.tmp.$kk
    rm tmpx
    else
tail -n $kk basrun.allene.$gamma.uniq.dat | head -n 1  | awk '{ for (i=4; i<=NF; i++) printf("%s\n",$i); }' > INC/sedfile.dat.tmp.$kk
    fi 
echo
echo
echo 'selected minima : ' $kk
echo
echo
cat  INC/sedfile.dat.tmp.$kk

paste sedfile.dat INC/sedfile.dat.tmp.$kk | awk '{print $1,$3}' > INC/sedfile.dat

export GMF=$newfmt 

cp inputhf.d12.par INC

cp bmax.dat INC
echo "bmax.dat"
cat INC/bmax.dat

#---run bas der flow----#
cd INC
 cp sedfile.dat basrunsed.dat
 ~/DGBO/basderfol.sh 100 | tee basderfol.out
 xxx=`tail -n 1 basderfol.out`
 echo "res:" $xxx
cd ..

if [ ! -e "bmax.dat" ]; then
 echo "bmax.dat not found"
 exit
fi

paste INC/sedfile.dat.tmp.$kk | awk '{print $1,$1}' > bounds_inc.dat

~/DGBO/boundsinc.sh bounds_inc.dat   bmax.dat > bounds_inc1.dat
~/DGBO/boundsinc.sh bounds_inc1.dat  bmax.dat > bounds_inc2.dat
~/DGBO/boundsinc.sh bounds_inc2.dat  bmax.dat > bounds_inc3.dat
~/DGBO/boundsinc.sh bounds_inc3.dat  bmax.dat > bounds_inc4.dat
~/DGBO/boundsinc.sh bounds_inc4.dat  bmax.dat > INC/bounds.dat  
echo "bounds.dat"
cat INC/bounds.dat


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
cp basrunsed.dat basrunsed.min$kk.dat

cd ..

done
echo "end loop over minima"

cd INC
echo "min gamma:"
sort -k 1 -g -r basrun.allene.$gamma.dat | uniq | tail -n 5
echo "min total:"
sort -k 2 -g -r basrun.allene.$gamma.dat | uniq | tail -n 5

awk '{print $3,$5,$7,$6}' notconv.$gamma.dat | sort -k 1 -g | grep -v NA | uniq > rmax0_enec.$gamma.dat
awk '{print $3,$6,$7}' notconv.$gamma.dat | sort -k 1 -g | grep -v NA | uniq > rmax0_enef.$gamma.dat
sort -k 2 -g -r rmax0_enec.$gamma.dat > rmax0_enec_sorted.$gamma.dat
sort -k 2 -g -r rmax0_enef.$gamma.dat > rmax0_enef_sorted.$gamma.dat

echo " ---over all final basis set---"
cat basrun.allene.$gamma.dat allene.$gamma.dat > tmpx
sort -k 1 -r -g  tmpx  | uniq > basrun.allene.$gamma.uniq.dat
rm tmpx
tail -n 1 basrun.allene.$gamma.uniq.dat  

#prepare for basrem
grep PAR inputhf.d12.par | awk '{print $1}' > tmpxx1
tail -n 1 basrun.allene.$gamma.uniq.dat |  awk '{ for (i=4; i<=NF; i++) printf("%s\n",$i); }' >tmpxx2
paste tmpxx1 tmpxx2 > basrunsed.optfinal$gamma.dat
rm tmpxx1 tmpxx2
gfile=`sort -k 5 -g -r notconv.$gamma.dat   | grep -v NA | uniq | tail -n 1 | awk '{printf "out.%s* ",$7}'`

mkdir optfinal$gamma
cp  basrunsed.optfinal$gamma.dat optfinal$gamma/sedfile.dat
cp inputhf.d12.par optfinal$gamma
cp gamma.info    optfinal$gamma  >& /dev/null
cp maxrmax.info  optfinal$gamma   >& /dev/null
cp $gfile        optfinal$gamma

cd  optfinal$gamma
~/DGBO/basrem.sh
cd ..

#INC
cd ..

