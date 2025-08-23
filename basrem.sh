#!/bin/bash
#set -x
if [ ! -e sedfile.dat ]; then
    echo "sedfile.dat missed"
    exit
fi

if [ ! -e inputhf.d12.par ]; then
    echo "inputhf.d12.par missed"
    exit
fi

cp sedfile.dat basrunsed.dat
echo "Running from sedfile.dat"
export BPROG="1.4"
enezero=` ~/DGBO/basrun.sh | awk '{print $1}'`
sss=`grep -m 1 -A 1 "END" inputhf.d12.par |tail -n 1`
ttt=`echo $sss | awk '{print $1,$2-1}'`
echo $sss
echo $ttt
echo "Running with one removed"
while read -r line; do
    par=`echo $line | awk '{print $1}'`
    echo $par
    occ=`grep -B 1 $par inputhf.d12.par | head -n 1 | awk '{print $4}'`
    if [ "$occ" == "0." ] || [ "$occ" == "0" ]; then 
    mkdir $par >& /dev/null
    tac inputhf.d12.par | sed "/$par/I,+1 d" | tac > $par/inputhf.d12.par
    sed -i "s/$sss/$ttt/g" $par/inputhf.d12.par
    cp sedfile.dat $par/basrunsed.dat
    cp *.info $par
    cd $par
    eneherefull=`~/DGBO/basrun.sh | awk '{print $1,$2}'`
    echo $eneherefull
    enehere=`echo $eneherefull | awk '{print $1}'`
    echo $enehere $enezero | awk '{print $1-$2'}
    cd ..
    else
     echo "occupied"						    
    fi						    
done < sedfile.dat
