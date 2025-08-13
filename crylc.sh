#!/bin/bash
name=$1

awk 'f;/END/{f=1}' $name | sed '/END/q' | head -n -2 > tmp_basis

ns=`grep "*" tmp_basis | wc -l | awk '{print $1}'`
#echo $ns

nn=`head -n 1 tmp_basis | awk '{print $1}'`
#echo $nn

nb=`head -n 1 tmp_basis | awk -v k=$ns '{print $2-k}'`
echo $nn $nb >tmp_basisx
tail -n+2 tmp_basis > tmp_basisz
sed -e '/*/{N;d;}' tmp_basisz >> tmp_basisx
#bse convert-basis  --in-fmt  crystal --out-fmt jaguar tmp_basisx tmp_basis_jag
# there could be ecp
ecp=`grep INPUT tmp_basisx | wc -l | awk '{print $1}'`
if [ "$ecp" == "1" ]; then
    ecpl=`grep -A 1 INPUT tmp_basisx | tail -n 1 | awk '{print $2+$3+$4+$5+$6+$7+4}'`
    head -1 tmp_basisx > tmp_basisxecp
    tail -n+$ecpl tmp_basisx >> tmp_basisxecp
    mv tmp_basisxecp   tmp_basisx
fi
~/DGBO/readlc2.x < tmp_basisx
rm tmp_basisz tmp_basis
