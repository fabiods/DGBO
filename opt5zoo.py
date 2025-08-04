import sys
import numpy as np
import os
import subprocess
#from scipy.optimize import minimize,direct,fmin_l_bfgs_b
#import pybobyqa
from zoopt import Dimension, ValueType, Dimension2, Objective, Parameter, ExpOpt, Solution
from ivvi import i2v,v2i

scal = [ 1 ,1 ,1]
cnt=0
myfmin=1e9


def ackleydd(solution):
   global myfmin
   global cnt
   x = solution.get_x()
   nn=len(x)
   cnt=cnt+1
   yy=[0]*nn
   for inn in range(nn):
       yy[inn]=i2v(x[inn],scal[inn],dig)
   val=(yy[0]-50.00)**2+(yy[1]-10.000)**2+(yy[2]-0.030)**2
   if (val < myfmin):
      myfmin=val
      print(x,cnt,val,myfmin)
   return val

def ackley(solution):
    """
    Ackley function for continuous optimization
    """
    global cnt
    global scal
    global dig
    global myfmin
    yy=[]
    x = solution.get_x()
    cnt=cnt+1
    nn=len(x)
    yy=[0]*nn
    for inn in range(nn):
       yy[inn]=i2v(x[inn],scal[inn],dig)
       
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
#      print(res.stdout)
#    if res.stdout == b"NA\n" :
#            quit()
#            print(x,0.0)
#            return 0.0
    strx=res.stdout.decode().split()     
    a=float(strx[0])
    if (a < 0 ):
         if (a < myfmin):     
            myfmin=a
            print(cnt,"NEW MIN ",x,myfmin)
         else:
            if (cnt % 100==1):
               print(cnt,"LOG ",x,a,myfmin)
    else:
         if (cnt % 100==1):
            print(cnt,"LOG ",x,a,myfmin) 
    return a


def checkbound(checkandupdate,xarr,lob,lobi,upb,upbi):
     global dig
     print("CHECK BOUNDS:")
     bok=True
     shift=10**(dig-1)
     for i in range(len(xarr)):
       print(" ",lob[i],"<",xarr[i],"<",upb[i])  
       if xarr[i] <= abs(lob[i]):
           print(" bound low violted",i)
           if lob[i] <0 :
               print(" bound low fixed",i)
           else:
               if checkandupdate == True :
                 if lobi[i] >1:
                    lobi[i]=lobi[i]-1
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
                if upbi[i] < 19*shift-1 :
                    # just increase of 1, even if the real bounds can be larger
                    upbi[i]=upbi[i]+1
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
        self.__count_limit = 300*(dim_size+1)

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
            print("stopping criterion holds, total_count: %d" % self.__total_count)
            return True
        else:
            return False


x0 = []
debug = True
debug = False
# Open the file in read mode
print(" ===== opt4zoo.py=========")
print("  require sedfile.dat , bounds.dat ,  input.d12.par ")
np.set_printoptions(linewidth=130)
datax0 = np.loadtxt('sedfile.dat', dtype='float', usecols=(1))
print (" data from sedfile.dat:")
print(datax0)

gamma=0
if os.path.isfile('gamma.info'):
  gamma=  np.loadtxt('gamma.info', dtype='float')
print("gamma",gamma)


nn=len(datax0)
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
  print("-----bounds iter---",counti) 
  myfmin=1e9
  lob =  np.loadtxt('bounds.dat', dtype='float', usecols=(0))
  upb =  np.loadtxt('bounds.dat', dtype='float', usecols=(1))
  print(counti,"lob:",lob)
  print(counti,"upb:",upb)

#  ggg=subprocess.run("~/DGBO/boundsinc.sh bounds.dat > boundsX.dat", shell=True, capture_output=False) 
#  lobX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(0))
#  upbX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(1)) 

  # bounds to boundsint.dat

# this is now useless: only for ordg and dig
  subprocess.run( "~/DGBO/boun2gmf.sh > boundsint.dat" , shell=True )
  ordg =  np.loadtxt('ordgdec0', dtype='float', usecols=(0))
  print(counti,"ordg:",ordg)
  scal=ordg
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
     binitial=checkbound(False,x0,lob,lobi,upb,upbi)
     if binitial == False:
         print("Error: sedfile.dat is NOT within bounds")
         print("maybe rerun cry2basrun")
         quit()
      # bounds.dat need to be saved                                                                              
     with open('bounds0.dat','w') as ft:       
          for j in range(len(lob)):
                print(lob[j],upb[j],file=ft)
                
  for inn in range(nn):
      lobi[inn]=v2i(abs(lob[inn]),scal[inn],dig)
      if lob[inn] < 0:
           lobi[inn]= - lobi[inn]
      upbi[inn]=v2i(abs(upb[inn]),scal[inn],dig)
      if upb[inn] < 0:
          upbi[inn] = -upbi[inn]
      
  bndsi = []
  for i, _ in enumerate(datax0):
    bndsi.append( [abs(lobi[i]) , abs(upbi[i]) ])    
  print("bounds_int:",bndsi)

  print("Check debug:")
  lobre=[0]*nn
  upbre=[0]*nn
  for inn in range(nn):
      lobre[inn]=i2v(lobi[inn],scal[inn],dig)
      upbre[inn]=i2v(upbi[inn],scal[inn],dig)
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
    # dim = Dimension2([(ValueType.CONTINUOUS, [-1, 1], 1e-6)]*dim_size)  # another way to form up the dimension object
    objective = Objective(ackley, dim)  # form up the objective function

    x0i=[]
    for i, _ in enumerate(datax0):
      iia=v2i(x0[i],scal[i],dig)  
      x0i.append(iia)
    print("x0int",x0i)  
    gx0 = Solution(x=x0i)

#x1 = Solution(x=[ 2 ,4 ,10],value=-7.45832442090000000000 ) 
#print(x0.get_x())
    budget = min(allsize,1000 * dim_size)  # number of calls to the objective function
    print("budget",budget)
#    parameter = Parameter(budget=budget,init_samples=[x1],seed=10,intermediate_result=True,intermediate_freq=1)
    parameter =      Parameter(budget=budget,init_samples=[gx0],exploration_rate = 0.5,seed=10,stopping_criterion=StoppingCriterion(),intermediate_result=False,intermediate_freq=100)
    print("trainsize",parameter.get_train_size())
#  parameter.set_train_size(20)
#  parameter.set_positive_size(2)
    res=ackley(gx0)
    print(res)
    solution_list = ExpOpt.min(objective, parameter, repeat=1, plot=False, plot_file='pippo.jpg')
  
    print(objective.get_history())
    print(cnt,parameter.get_budget())
#    print(solution_list)
    for solution in solution_list:
      print(" call at the minimum:",solution.get_x())     
      res=ackley(solution)
    
     # bounds.dat need to be updated
      with open('bounds.dat','w') as ft:
          for j in range(len(lob)):
                print(lob[j],upb[j],file=ft)
#    ggg=subprocess.run("~/DGBO/boundsinc.sh bounds.dat > boundsX.dat", shell=True, capture_output=False)   
#    lobX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(0))
#    upbX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(1))

      xarr=[0]*nn
      for inn in range(nn):
         xarr[inn]=i2v(solution.get_x()[inn],scal[inn],dig)
         
      
#      ggg=subprocess.run("grep dstr br.out", shell=True, stdout=subprocess.PIPE)
#      ggsg=ggg.stdout.decode('UTF-8').split()
#      ggsx=ggsg[1:]
#      xarr = np.array(ggsx, dtype='float')
      print("x gmf",xarr)

      bondsok=checkbound(True,xarr,lob,lobi,upb,upbi)
#      print("new lob:",lob)
#      print("new upb:",upb)
      
      if debug == False:    
        print(" call derviatives:")
        ggg=subprocess.run("~/DGBO/basdergmf.sh", shell=True,stdout=subprocess.PIPE )
#  ggg=subprocess.run("~/basdergmf.sh", shell=True, capture_output=False)  
        ggsg=ggg.stdout.decode('UTF-8')
        print(ggsg)
        ggsgl=ggsg.split()
        minggt=ggsgl[-1]
        minggx=ggsgl[-2]
        minncx=ggsgl[-5]
        print(" fun", solution.get_value(), " res: ",xarr," opt: zoo , x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",minggx,minggt,"conv:",minncx,"boundok:",bondsok)
#  compute follow  
        print(ackley(solution))   
        ggg=subprocess.run("cat basrunsed.dat", shell=True, stdout=subprocess.PIPE)
        print(ggg.stdout.decode('UTF-8'))
        ggg=subprocess.run("~/DGBO/basderfol.sh", shell=True)
        menergylast=np.loadtxt('basderfol.energy', dtype='float', usecols=(1))
        print("energylast",menergylast)
        mxarr=np.loadtxt('basrunsed.dat', dtype='float', usecols=(1))
        print("mxarr",mxarr)
    
#    ggg=subprocess.run("cat basrunsed.dat", shell=True, stdout=subprocess.PIPE)
        print(" call derviatives fol:")
        ggg=subprocess.run("~/DGBO/basdergmf.sh", shell=True, stdout=subprocess.PIPE)
        ggsg=ggg.stdout.decode('UTF-8')
        print(ggsg)
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
   print("scal:",scal)
   fbondsok=checkbound(True,mxarr,lob,lobi,upb,upbi)
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   print("scal",scal)
   print(fbondsok)  
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
   print("check lower----")
   mxarr=x0/2
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   print("scal:",scal)
   fbondsok=checkbound(True,mxarr,lob,lobi,upb,upbi)
   print("lob:",lob,"upb:",upb)
   print("lobi:",lobi,"upbi:",upbi)
   print("scal",scal)
   print(fbondsok)  
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
  else:
   fbondsok=checkbound(True,mxarr,lob,lobi,upb,upbi)
   print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)
  
#  quit()
#    update bounds     
  with open('bounds.dat','w') as ft:                                       
   for j in range(len(lob)):                                       
     print(lob[j],upb[j],file=ft)
     
  counti=counti+1
print("END LOPP BONDS")        
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
