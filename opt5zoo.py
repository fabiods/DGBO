import sys
import numpy as np
import os
import subprocess
#from scipy.optimize import minimize,direct,fmin_l_bfgs_b
#import pybobyqa
from zoopt import Dimension, ValueType, Dimension2, Objective, Parameter, ExpOpt, Solution
from ivvi import i2v,v2i


def my_sign(x):
     return int(x > 0) - int(x < 0)

class Scaling:
    def __init__(self, nn):
      self.data = [1]*nn
      
    def set(self,n,val):
      self.data[n] = val

    def aset(self,data):
      for i in range(len(self.data)): 
        self.data[i]=data[i]
      
    def get(self,n):
      return self.data[n]

    def aget(self):
       return self.data

    def mul(self,n):
      self.data[n]=10*self.data[n]

    def div(self,n):
      self.data[n]=self.data[n]/10

    def print(self,name):
      print(name,self.data)

    def checkbound(self,checkandupdate,xarr,fixedcheck):
      global dig
      global upb,lob,upbi,lobi
      global bmax   
      print("CHECK BOUNDS:")
      bok=True
      shift=10**(dig-1)
      for i in range(len(xarr)):
       print(" ",lob[i],"<",xarr[i],"<",upb[i])  
       ixx=v2i(xarr[i],self.get(i),dig)
       print(" ",lobi[i],"<",ixx,"<",upbi[i])  
       if xarr[i] <= abs(lob[i]):
           print(" bound low violted",i)
           if lob[i] <0 :
               print(" bound low fixed",i)
               if fixedcheck == True :
                 bok=False
           else:
               bok=False
               if checkandupdate == True :
                 if lobi[i] >1:
#old                    lobi[i]=lobi[i]-1
                    ldiff=abs(lobi[i])-ixx
                    if ldiff == 0:
                      print("bounds lobi", i, " from ",  lobi[i], " to ",lobi[i]-1)
                      lobi[i]=lobi[i]-1
                    else:
                     print("bounds large deviation ",i," :decreasing by ",ldiff+1)
                     lobi[i]=max(1,lobi[i]-int(ldiff/1)-1) 
                 else :
                    print(" scal /10 ",i)
                    # minimum values is 9 ,99 ,999 
                    lobi[i]=9*shift
                    self.div(i)
                    # if scale change, then upb change to the maximum
                    print(" min: ", self.get(i)*10.0*(10.0-1.0/shift))  
                    upbi[i]=v2i( self.get(i)*10.0*(10.0-1.0/shift) ,self.get(i) ,dig)
                    print(" upboundsi",upbi[i])                      
                    upb[i]=i2v(upbi[i], self.get(i) ,dig)
                    print(" upbounds",upb[i])
                 # recompute lob   
                 lob[i]=i2v(lobi[i], self.get(i) ,dig)          
       if xarr[i] >= abs(upb[i]):
           print(" bound up violated",i)
           if upb[i] <0 :
               print(" bound up fixed",i)
               if fixedcheck == True :
                  bok=False
           else :
              bok=False    
              if checkandupdate == True :
                if upbi[i] < 19*shift-1 :
                    # just increase of 1, even if the real bounds can be larger
#old                    upbi[i]=upbi[i]+1
                    ldiff=ixx-abs(upbi[i])
                    if ldiff==0 : 
                      print("bounds upb", i, " from ",  upbi[i], " to ",upbi[i]+1)
                      upbi[i]=upbi[i]+1
                    else:
                      print("bounds large deviation of ",i," : increasing by ",ldiff+1)
                      upbi[i]=upbi[i]+int(ldiff/1)+1    
                else :
                    print(" scal *10 ",i)
                    self.mul(i)
                    # maxmimum values is 10 (d=1), 100 (d=2) ,1000(d=3)
                    upbi[i]=shift*10 
                    # if scale change lob change to the minimun
#                   print(" min: ", scal[i]/shift)
                    lobi[i]=v2i( self.get(i)/shift ,self.get(i) ,dig)
#                    print("loboundsi",lobi[i])
                    lob[i]=i2v(lobi[i],self.get(i) ,dig)
#                    print("lobounds",lob[i])
                # recompute upb    
                upb[i]=i2v(upbi[i], self.get(i)  ,dig)
#                print("upbi",upbi[i],"upb",upb[
                if bmax[i] > 0:   
                  if abs(upb[i]) > bmax[i]:
                    bmaxint=v2i( bmax[i] ,self.get(i) ,dig)
                    upb[i]= -i2v(bmaxint,self.get(i) ,dig)
                    upbi[i]=-bmaxint
                    print("bmax reached",bmax[i],bmaxint,upb[i])
      return bok

def ackleydd(solution):
   global myfmin
   global cnt
   global scal  
   global debug
   debug = True
   x = solution.get_x()
   nn=len(x)
   cnt=cnt+1
   yy=[0]*nn
   for inn in range(nn):
       yy[inn]=i2v(x[inn],scal.get(inn),dig)
   val=(yy[0]-50.00)**2+(yy[1]-10.000)**2+(yy[2]-0.030)**2
   if (val < myfmin):
      myfmin=val
      print(x,cnt,val,myfmin)
   return val

def ackley(solution):
    """
    Ackley function for continuous optimization
    """
    global cnt   # for all the simulations 
    global cntp  # for just one simulations (i.e. bound-iter)
    global cntprec # previous new min 
    global scal
    global dig
    global myfmin
    yy=[]
    x = solution.get_x()
    cnt=cnt+1
    cntp=cntp+1
    nn=len(x)
    yy=[0]*nn
    for inn in range(nn):
       yy[inn]=i2v(x[inn],scal.get(inn),dig)
       
    if nn==2:
        res=subprocess.run( "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) , shell=True, stdout=subprocess.PIPE)
    if nn==3:
#         print(x,scal)
#         quit()
         res=subprocess.run( "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2]) , shell=True,stdout=subprocess.PIPE)
    if nn==5:
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4])  , shell=True, stdout=subprocess.PIPE)  
    if nn==6:
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4]) + " " + str(yy[5]) , shell=True, stdout=subprocess.PIPE)
    if nn==7:
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4]) + " " + str(yy[5])+ " " + str(yy[6]) , shell=True, stdout=subprocess.PIPE)
    if nn==8:                                                                                                                                                                               
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4]) + " " + str(yy[5])+ " " + str(yy[6]) + " " + str(yy[7]) , shell=True, stdout=subprocess.PIPE) 
    if nn==9:
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4]) + " " + str(yy[5])+ " " + str(yy[6]) + " " + str(yy[7])  + " " + str(yy[8]) , shell=True, stdout=subprocess.PIPE)         
    if nn=10:
        res=subprocess.run(  "~/DGBO/basrun.sh " + str(yy[0]) + " " + str(yy[1]) + " " + str(yy[2])+ " " + str(yy[3]) + " " + str(yy[4]) + " " + str(yy[5])+ " " + str(yy[6]) + " " + str(yy[7])  + " " + str(yy[8])  + " " + str(yy[9]) , shell=True, stdout=subprocess.PIPE)
         
#      print(res.stdout)
#    if res.stdout == b"NA\n" :
#            quit()
#            print(x,0.0)
#            return 0.0
    if res.returncode != 0 :
         print("basrun failed")
         print(x,yy)
         sys.exit(1)
    strx=res.stdout.decode().split()     
    a=float(strx[0])
#    if (a < 0 ):
    if (a < myfmin):     
            myfmin=a
            if cntp != 1:
               cntdiff=cnt-cntprec
               cntprec=cnt
            else:  
               cntdiff=0
               cntprec=cnt
            print(cnt,"NEW MIN ",x,myfmin,"countdiff",cntdiff)
            if (cntp == 1) :
                 print ("fun ",myfmin," res: ",x)
    else:
            if (cnt % 100==1):
               print(cnt,"LOG ",x,a,myfmin)
#    else:
#         if (cnt % 100==1):
#            print(cnt,"LOG ",x,a,myfmin) 
    return a


def checkboundold(checkandupdate,xarr,lob,lobi,upb,upbi,scal):
     global dig
     print("CHECK BOUNDS:")
     bok=True
     shift=10**(dig-1)
     for i in range(len(xarr)):
       print(" ",lob[i],"<",xarr[i],"<",upb[i])  
       ixx=v2i(xarr[i],scal[i],dig)
       print(" ",lobi[i],"<",ixx,"<",upbi[i])  
       if xarr[i] <= abs(lob[i]):
           print(" bound low violted",i)
           if lob[i] <0 :
               print(" bound low fixed",i)
           else:
               if checkandupdate == True :
                 if lobi[i] >1:
                    ldiff=abs(lobi[i])-ixx
                    if ldiff <= 1:
                     lobi[i]=lobi[i]-1
                    else:
                     print("large deviation, decreasing by half of",ldiff)
                     lobi[i]=max(1,lobi[i]-int(ldiff/1)) 
                 else :
                    print(" scal /10 ",i)
                    # minimum values is 9 ,99 ,999 
                    lobi[i]=9*shift
                    scal[i]=scal[i]/10
                    # if scale change, then upb change to the maximum
                    print(" min: ", scal[i]*10.0*(10.0-1.0/shift))  
                    upbi[i]=v2i( scal[i]*10.0*(10.0-1.0/shift) ,scal[i],dig)
                    print(" upbi",upbi[i])                      
                    upb[i]=i2v(upbi[i],scal[i],dig)
                    print(" upb",upb[i])
                 # recompute lob   
                 lob[i]=i2v(lobi[i],scal[i],dig)
           bok=False          
       if xarr[i] >= abs(upb[i]):
           print(" bound up violated",i)
           if upb[i] <0 :
               print(" bound up fixed",i)
           else :
              if checkandupdate == True :
                if abs(upbi[i]) < 19*shift-1 :
                    # just increase of 1, even if the real bounds can be larger
                    ldiff=ixx-abs(upbi[i])
                    if ldiff<=1 : 
                      upbi[i]=upbi[i]+1
                    else:
                      print("large deviation: using half of ldiff")
                      upbi[i]=upbi[i]+int(ldiff/1)    
                else :
                    print(" scal *10 ",i)
                    scal[i]=scal[i]*10
                    # maxmimum values is 10 (d=1), 100 (d=2) ,1000(d=3)
                    upbi[i]=shift*10 
                    # if scale change lob change to the minimun
#                    print(" min: ", scal[i]/shift)
                    lobi[i]=v2i( scal[i]/shift ,scal[i],dig)
#                    print("lobi",lobi[i])
                    lob[i]=i2v(lobi[i],scal[i],dig)
#                    print("lob",lob[i])
                # recompute upb    
                upb[i]=i2v(upbi[i],scal[i],dig)
#                print("upbi",upbi[i],"upb",upb[i])
           bok=False
           
     return bok

class StoppingCriterion:
    def __init__(self):
        self.__best_result = 0
        self.__count = 0
        self.__total_count = 0
         # reduced to 100, sep 3 2025
        self.__count_limit = max(500,100*(dim_size))

    def check(self, optcontent):
        """
        :param optcontent: an instance of the class RacosCommon. Several functions can be invoked to get the contexts of the optimization, which are listed as follows,
        optcontent.get_best_solution(): get the current optimal solution
        optcontent.get_data(): get all the solutions contained in the current solution pool
        optcontent.get_positive_data(): get positive solutions contained in the current solution pool
        optcontent.get_negative_data(): get negative solutions contained in the current solution pool

        :return: bool object.

        """
        self.__total_count += 1
        content_best_value = optcontent.get_best_solution().get_value()
        if content_best_value == self.__best_result:
            self.__count += 1
        else:
            self.__best_result = content_best_value
            self.__count = 0
        if self.__count >= self.__count_limit:
            print("[zoopt] stopping criterion holds, total_count: %d" % self.__total_count)
            return True
        else:
            return False


x0 = []
x0re =[]
debug = True
debug = False
cnt = 0
# Open the file in read mode
print(" ===== opt5zoo.py=========")
print("  require sedfile.dat , bounds.dat , bmax.dat,  input.d12.par ")
np.set_printoptions(linewidth=130)
datax0 = np.loadtxt('sedfile.dat', dtype='float', usecols=(1))
print (" data from sedfile.dat:")
print(datax0)

bmax=np.loadtxt('bmax.dat', dtype='float', usecols=(1))
print( " bmax from bmax.dat")
print(bmax)

GMF=os.getenv("GMF")

gamma=0
if os.path.isfile('gamma.info'):
  gamma=  np.loadtxt('gamma.info', dtype='float')
print("gamma",gamma)


nn=len(datax0)
x0=[0]*nn
x0re=[0.0]*nn
scal=Scaling(nn)
gscal=Scaling(nn)
print( " nn:",nn)

#lob =  np.loadtxt('bounds.dat', dtype='float', usecols=(0))
#print(lob)
#upb =  np.loadtxt('bounds.dat', dtype='float', usecols=(1))
#print(upb)

#bnds = []
#for i, _ in enumerate(data):
#      bnds.append( (lob[i] , upb[i] ))
#    if i == 0:
#        bnds.append((data[1]*1.2, data[0]*2))
#    elif 1 <= i < nn - 1:
#        bnds.append((data[i+1]*1.0, data[i-1]*1.0))
#    else:
#        bnds.append( (data[nn-1]/2, data[nn-2]*1.2) )
#print(" bounds: from file",bnds)



#quit()
#print(enumerate(data))
#x0 = np.array([2, 1, 0.2])
#print(x0)
#quit()
#bnds= ((1.5, 4), (0.5, 1.0), (0.06, 0.3 ))
#
#global
# basinhopping maybered
# direct no
# dual_annealing maybered
# diffevo  no
# shgo maybe

x0=datax0
bondsok=False
fbondsok=False
counti=0

while bondsok == False or fbondsok == False:
# nothing is in memory: 
# from bounds.dat -> lob,upb,orgd,dig,lobi,upbi
# x0 is always from datax0 (float)
  print("-----bounds iter---",counti) 
  myfmin=1e9
  cntp=0
  cntprec=0
  lob =  np.loadtxt('bounds.dat', dtype='float', usecols=(0))
  upb =  np.loadtxt('bounds.dat', dtype='float', usecols=(1))
  print(counti,"lobounds:",lob)
  print(counti,"upbounds:",upb)

#  ggg=subprocess.run("~/DGBO/boundsinc.sh bounds.dat > boundsX.dat", shell=True, capture_output=False) 
#  lobX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(0))
#  upbX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(1)) 

  # bounds to boundsint.dat

# this is now useless: only for ordg and dig
  subprocess.run( "~/DGBO/boun2gmf.sh > boundsint.dat" , shell=True )
  ordg =  np.loadtxt('ordgdec0', dtype='float', usecols=(0))
  print(counti,"ordg:",ordg)
  scal.aset(ordg)
  scal.print("scal")   
  lobi =  np.loadtxt('boundsint.dat', dtype='int', usecols=(0))
  upbi =  np.loadtxt('boundsint.dat', dtype='int', usecols=(1))
  if lobi[0] <= 9:
      dig=1
  elif lobi[0] <=99:
      dig=2
  elif lobi[0] <=999:
      dig=3
  print("dig:",dig)
  
  if counti == 0: 
     binitial=scal.checkbound(False,x0,True)
     if binitial == False:
         print("Error: sedfile.dat is NOT within bounds")
         print("maybe rerun cry2basrun")
#         quit()
      # bounds.dat need to be saved  
     else:
         print("Initialbounds=True")
         
     with open('bounds0.dat','w') as ft:       
          for j in range(len(lob)):
                print(lob[j],upb[j],file=ft)
                
  for inn in range(nn):
      lobi[inn]=v2i(abs(lob[inn]),scal.get(inn),dig)
      if lob[inn] < 0:
           lobi[inn]= - lobi[inn]
      upbi[inn]=v2i(abs(upb[inn]),scal.get(inn),dig)
      if upb[inn] < 0:
          upbi[inn] = -upbi[inn]
      
  bndsi = []
  for i, _ in enumerate(datax0):
    bndsi.append( [abs(lobi[i]) , abs(upbi[i]) ])    
  #internal one : must be positive     
  print("bounds_int:",bndsi)

  print("Check debug:")
  lobre=[0]*nn
  upbre=[0]*nn
  for inn in range(nn):
     lobre[inn]= my_sign(lobi[inn]) * i2v(abs(lobi)[inn],scal.get(inn),dig)
     upbre[inn]= my_sign(upbi[inn]) * i2v(abs(upbi)[inn],scal.get(inn),dig)


  for inn in range(nn):
      if abs(lob[inn]-lobre[inn]) > 1.E-8:
         print(lob[inn],lobre[inn])
  for inn in range(nn):
      if abs(upb[inn]-upbre[inn]) > 1.E-8:      
         print(upb[inn],upbre[inn])
            
  runthis=True

  if runthis == True:
    dim_size = nn  # dimensions
#dim_regs = [[1, 6], [ 2,10] , [6,10]]   # dimension range
    dim_regs = bndsi #<======================= bounds !!!

    dim_tys = [False]*nn   # dimension type : real
    dim_ord = [True]*nn   # ordered
#  print(dim_tys)
#quit()
    dim = Dimension(dim_size, dim_regs, dim_tys, dim_ord)  # form up the dimension object
    allsize=dim.limited_space()[1]
    print("allsize",allsize)
    if allsize < 0:
         print("HARD ERROR: negative allsize")
         print("check the bounds")
         sys.exit(1)
    # dim = Dimension2([(ValueType.CONTINUOUS, [-1, 1], 1e-6)]*dim_size)  # another way to form up the dimension object
    objective = Objective(ackley, dim)  # form up the objective function

    x0i=[]
    for i, _ in enumerate(datax0):
# for large job, we have to update x0        
     iia=v2i(x0[i],scal.get(i),dig)  
     x0i.append(iia)
    print("x0int",x0i)  
    gx0 = Solution(x=x0i)
       
    for i in range(nn):
     iia=v2i(x0[i],scal.get(i),dig)
     x0re[i]= i2v(iia,scal.get(i),dig)
    print("x0real",x0re)

#x1 = Solution(x=[ 2 ,4 ,10],value=-7.45832442090000000000 ) 
#print(x0.get_x())
    budget = min(allsize,1000 * dim_size)  # number of calls to the objective function
    print("budget",budget)
#    parameter = Parameter(budget=budget,init_samples=[x1],seed=10,intermediate_result=True,intermediate_freq=1)
    parameter =      Parameter(budget=budget,init_samples=[gx0],exploration_rate = 0.5,seed=10,precision=1.0E-7,stopping_criterion=StoppingCriterion(),intermediate_result=False,intermediate_freq=100)
    
    pkl=parameter.get_train_size()
    print("trainsize",pkl)
#    if nn<=7 and pkl>20:
#       parameter.set_train_size(20)
#       parameter.set_positive_size(2)
#       print("trainsize",parameter.get_train_size())
    res=ackley(gx0)
    print(res)
    solution_list = ExpOpt.min(objective, parameter, repeat=1, plot=False, plot_file='pippo.jpg')
  
    print(objective.get_history())
    print(cnt,parameter.get_budget())
#    print(solution_list)
    for solution in solution_list:
      solx=solution.get_x()
      print(" call at the minimum:",solx)     
      res=ackley(solution)
    
     # bounds.dat need to be updated
      with open('bounds.dat','w') as ft:
          for j in range(len(lob)):
                print(lob[j],upb[j],file=ft)
#    ggg=subprocess.run("~/DGBO/boundsinc.sh bounds.dat > boundsX.dat", shell=True, capture_output=False)   
#    lobX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(0))
#    upbX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(1))

#          this is ok but there are numeric noise error
      xarrnew=[0]*nn
      xarr=[0]*nn
      for inn in range(nn):
         xarrnew[inn]=i2v(solx[inn],scal.get(inn),dig)
         xarr[inn]=xarrnew[inn] 
# update x0 at the end           
      if debug == False: 
           
#       ggg=subprocess.run("grep dstr br.out", shell=True, stdout=subprocess.PIPE)
#       ggsg=ggg.stdout.decode('UTF-8').split()
#       ggsx=ggsg[1:]
#       xarr = np.array(ggsx, dtype='float')
#       print("x gmf",xarr)
        for inn in range(nn):
             ddd=GMF % xarrnew[inn]
             xarr[inn]=float(ddd)
        print("x gmf",xarr)   

# WRONG in python: this copy as pointer !! 
#      gscal=scal

      gscal.aset(scal.aget())
#     scal must be the older one, because you will call basder

      bondsok=gscal.checkbound(True,xarr,False)
      if bondsok == False :       
       print("new lobounds:",lob)
       print("new upbounds:",upb)
       print("new loboundsi:",lobi) 
       print("new upboundsi:",upbi)
       scal.print("scal")
       gscal.print("gscal")
      else :
        print("checkbounds=True")
           
      if debug == False:    
        print(" call derviatives:")
        ggg=subprocess.run("~/DGBO/basdergmf.sh", shell=True,stdout=subprocess.PIPE )
#  ggg=subprocess.run("~/basdergmf.sh", shell=True, capture_output=False)  
        ggsg=ggg.stdout.decode('UTF-8')
        print(ggsg)
        if ggg.returncode != 0 :
          print("~/DGBO/basdergmf.sh failed")
          sys.exit(1)
             
        
       
        ggsgl=ggsg.split()
        minggt=ggsgl[-1]
        minggx=ggsgl[-2]
        minncx=ggsgl[-5]
        print(" fun", solution.get_value(), " res: ",xarr," opt: zoo , x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",minggx,minggt,"conv:",minncx,"boundok:",bondsok)
#  compute follow  
        print(ackley(solution))   
        ggg=subprocess.run("cat basrunsed.dat", shell=True, stdout=subprocess.PIPE)
        print(ggg.stdout.decode('UTF-8'))
           
        ggg=subprocess.run("~/DGBO/basderfol.sh 10", shell=True) #,stdout=subprocess.PIPE)
                                                                 #print(ggg.stdout.decode('UTF-8'))
        if ggg.returncode != 0 :
             print("~/DGBO/basderfol.sh failed")
             sys.exit(1)
             
        menergylast=np.loadtxt('basderfol.energy', dtype='float', usecols=(1))
        print("energylast",menergylast)
        mxarr=np.loadtxt('basrunsed.dat', dtype='float', usecols=(1))
        print("mxarr",mxarr)
    
#    ggg=subprocess.run("cat basrunsed.dat", shell=True, stdout=subprocess.PIPE)
        print(" call derviatives fol:")
        ggg=subprocess.run("~/DGBO/basdergmf.sh", shell=True, stdout=subprocess.PIPE)
        ggsg=ggg.stdout.decode('UTF-8')
        print(ggsg)
        if ggg.returncode != 0 :
             print("~/DGBO/basdergmf.sh failed")     
             sys.exit(1)
        ggsgl=ggsg.split()
        fminggt=ggsgl[-1]
        fminggx=ggsgl[-2]
        fminncx=ggsgl[-5]
      else:
        minggx=0
        minggt=0
        minncx=0
        print(" fun", solution.get_value(), " res: ",xarr," opt: zoo , x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",minggx,minggt,"conv:",minncx,"boundok:",bondsok)    
        menergylast=0
        fminggx=0
        fminggt=0
        fminncx=0
        mxarr=xarr
    print("END LOOP SOLUTION")  
#    print(fminggx,fminggt,fminncx,fminggt)
  else :
    menergylast=0
    fminggx=0
    fminggt=0
    fminncx=0
    mxarr=x0
    bondsok=True
    print("RUNTHIS SKIPPED")

  if True == False:  
   print("check-----upper---")
   mxarr=x0*2
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   scal.print("scal")
   fbondsok=scal.checkbound(True,mxarr,True)
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   scal.print("scal")
   print(fbondsok)  
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
   print("check lower----")
   mxarr=x0/2
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   scal.print("scal")
   fbondsok=scal.checkbound(True,mxarr,True)
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   scal.print("scal")
   print(fbondsok)  
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
  else:
   fbondsok=gscal.checkbound(True,mxarr,False)
   if fbondsok == False:     
    print("new lobounds:",lob)
    print("new upbounds:",upb)
    print("new loboundsi:",lobi) 
    print("new upboundsi:",upbi)
    scal.print("scal")
    gscal.print("gscal")
   else:
    print("fcheckbounds=True")    
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
  
#  quit()
  with open('bounds.dat','w') as ft:                                       
   for j in range(len(lob)):                                       
     print(lob[j],upb[j],file=ft)
        
  x0=xarrnew    
  counti=counti+1
print("END LOPP BONDS")     
print("opt5zoo ENDED")
#    print(ggg.stdout.decode('UTF-8'))

#-------------------bounds part----------------
#    x0ff = solution.get_x()
#    print("Check Boundary:")
#    bondsok=True
#    for i in range(len(x0ff)):
#      print(lobi[i],x0ff[i],upbi[i])  
#      if x0ff[i] <= lobi[i]:
#          print("bound low violted",i)
#          if lobi[i] >= 2 :
#            lobi[i]=lobi[i]-1
#            bondsok=False
#      if x0ff[i] >= upbi[i]:
#          print("bound up violated",i)
#          upbi[i]=upbi[i]+2
#          bondsok=False

          #
#    print(" fun", solution.get_value(), " res: ",xarr," opt: zoo , x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",ggsglx,ggsglt,"bounds:",bondsok)      
    #    print(len(solution_list))

#if __name__ == '__main__':
#    minimize_ackley_continuous()
