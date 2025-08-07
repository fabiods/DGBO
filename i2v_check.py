
import numpy as np
from ivvi import i2v,v2i
        
print("v2i")
scal=0.001
for d in range(1,3):
 skip=1+(d-1)*6      
 xshift=10**(d-1)
 print()
 print("digits----------",d)
 print()
 print("**************i2v")
 for k in range (1*xshift,19*xshift):
   print()     
   print(">>",k)      
   a=i2v(k,scal,d)
   ia=v2i(a,scal,d)
   print("%d %5.3E %d" %(k,a,ia))
 print()
 print("*************************v2i")
 print()
 for k in range(1,95*xshift,skip):
       a=k*scal/xshift
       print()
       print(">>",a)
       ai  =v2i(a,scal,d)
       aia=i2v(ai,scal,d)
       if d==1:
              print("%2.0E %d %2.0E" %(a,ai,aia))
       if d==2:
              print("%3.1E %d %3.1E" %(a,ai,aia))          

print()
print("cases: scal=",scal)
aaa=i2v(11,scal,1)
print(aaa, "should be 2E-2")
print()
aaa=i2v(101,scal,2)
print(aaa,"should be 1.1E-2")
print()
iii=v2i(0.110,scal,2)
print(aaa,"should be ")

aaa=v2i(5.6E-3,scal,2)
print(aaa)
# DIGIT 1:   1---9 - 18  < 19
# DIGIT 2:   10--99- 189  <190 
# DIGIT 3:   100-999-1899 <1900
# dig:2
# 10  => 1.0E-3
# ..
# 99  => 9.9E-3
# 100 => 1.0E-2
# 101 => 1.1E-2
# quit()
#
# print("--2--")
# for k in range (1,190):
#     print(k,i2v(k,0.01,2))   
