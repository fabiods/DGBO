def i2v(vali,scal,d):
#       print("i2v(%d %f %d)" %(vali,scal,d))
       shift=10**(d-1)  # 1 10 100
       tens=10*shift    # 10 100 1000
       scals=scal/shift
#    if digits == 1:
       if vali <   tens:
          ttt= vali*scals
       elif vali >=19*shift:
#           print("ERROR i2v",vali,scal,d)
           quit()
       else: # i0*shif < []  < 19*shift
#           print("i2v.vali%",(vali%tens))    
           ttt= ( shift+(vali%tens) ) *scals*10
#       print("i2v ->",ttt)    
       return ttt
#    elif digits ==2:
#        if vali <= 100:
#            return vali*scal
#        else:
#            return (int(vali/100)*100 +(vali%100)*10) *scal

def v2i(val,scal,d):
       shift=10**(d-1)   # 1 10 100
       tens=10*shift     # 10 100 1000
       scals=scal/shift  # E-3 E-4 E-5 
       vs=round(val/(scals))
       imaxvs=19*shift-1  
#      print("v2i.vs",vs)
       if vs <=tens:
            return vs
       elif vs>=ivsmax:
            print("ERROR in v2i()",val,scal,d,":",vs,"Cannot be coded")
            print(val," is outside the margins",i2v(1,scal,d),",",i2v(ivsmax,scal,d))
            quit()
       else:
# val=1.1E-2 , scal E-3
# scals=E-4
# vs=110
# vss=11
              
            vss=round(val/(scals*10)) # val/ E-2 E-3 E-4
#            print("v2i.vss" ,vss)
            return 10*shift+(vss-shift)
#    elif digits ==2:
#        if vs<100:
#            return vs*shift
#        else:
#            vss=round(val/(scals*10))
#            return 100+(vss-1)
