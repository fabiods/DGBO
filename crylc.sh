#!/bin/bash
name=$1

awk 'f;/END/{f=1}' $name | sed '/END/q' | head -n -2 > tmp_basis
bse convert-basis  --in-fmt  crystal --out-fmt jaguar tmp_basis tmp_basis_jag
~/DGBO/readlc.x < tmp_basis_jag
