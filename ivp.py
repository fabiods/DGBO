import numpy as np
import sys
from ivvi import i2v,v2i


a=float(sys.argv[1])
scal=float(sys.argv[2])
dig=int(sys.argv[3])

#print(a,scal,dig)
ia=v2i(a,scal,dig)

if ia > 1:
  ia=ia-1
else:
  scal=scal/10
  ia=9

an=i2v(ia,scal,dig)
if dig==1:
    print("%2.0E" %(an))
elif dig==2:
    print("%3.1E" %(an))
elif dig==3:
    print("%4.2E" %(an))
