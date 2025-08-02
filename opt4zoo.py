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

# Open the file in read mode
print(" ===== opt4zoo.py=========")
print("  require sedfile.dat , bounds.dat input.d12.par ")
np.set_printoptions(linewidth=130)
data = np.loadtxt('sedfile.dat', dtype='float', usecols=(1))
print (" data from sedfile.dat:")
print(data)

gamma=0
if os.path.isfile('gamma.info'):
  gamma=  np.loadtxt('gamma.info', dtype='float')
print("gamma",gamma)


nn=len(data)
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

x0=data
bondsok=False
fbondsok=False

while bondsok == False or fbondsok == False:
  myfmin=1e9
  lob =  np.loadtxt('bounds.dat', dtype='float', usecols=(0))
  upb =  np.loadtxt('bounds.dat', dtype='float', usecols=(1))
  print(lob)
  print(upb)
#  ggg=subprocess.run("~/DGBO/boundsinc.sh bounds.dat > boundsX.dat", shell=True, capture_output=False) 
#  lobX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(0))
#  upbX =  np.loadtxt('boundsX.dat', dtype='float', usecols=(1)) 

  # bounds to boundsint.dat

# this is now useless: only for ordg
  subprocess.run( "~/DGBO/boun2gmf.sh > boundsint.dat" , shell=True )
  ordg =  np.loadtxt('ordgdec0', dtype='float', usecols=(0))
  print("ordg",ordg)
  scal=ordg

  lobi =  np.loadtxt('boundsint.dat', dtype='int', usecols=(0))
  upbi =  np.loadtxt('boundsint.dat', dtype='int', usecols=(1))
  if lobi[0] <= 9:
      dig=1
  elif lobi[0] <=99:
      dig=2
  elif lobi[0] <=999:
      dig=3
  for inn in range(nn):
      lobi[inn]=v2i(lob[inn],scal[inn],dig)
      upbi[inn]=v2i(upb[inn],scal[inn],dig)
      
  bndsi = []
  for i, _ in enumerate(data):
    bndsi.append( [lobi[i] , upbi[i] ])    
  print("bounds int",bndsi)

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
  for i, _ in enumerate(data):
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
  print(solution_list)
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
              
    ggg=subprocess.run("grep dstr br.out", shell=True, stdout=subprocess.PIPE)
    ggsg=ggg.stdout.decode('UTF-8').split()
    ggsx=ggsg[1:]
    xarr = np.array(ggsx, dtype='float')
    print("x gmf",xarr)
    
    bondsok=True
    for i in range(len(xarr)):
      print(lob[i],xarr[i],upb[i])  
      if xarr[i] <= lob[i]:
          print("bound low violted",i)
          lobi[i]=lobi[i]-1
          lob[i]=i2v(lob[i],scal[i],dig)
          bondsok=False
      if xarr[i] >= upb[i]:
          print("bound up violated",i)
          upbi[i]=upbi[i]+1
          upb[i]=i2v(upb[i],scal[i],dig)   
          bondsok=False
          
    
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
#    print(fminggx,fminggt,fminncx,fminggt)
    fbondsok=True
    
    for i in range(len(mxarr)):
      print(lob[i],mxarr[i],upb[i])  
      if mxarr[i] <= lob[i]:
          print("bound low violted",i)
          lobi[i]=lobi[i]-1
          lob[i]=i2v(lob[i],scal[i],dig)
          fbondsok=False
      if mxarr[i] >= upb[i]:
          print("bound up violated",i)
          upbi[i]=upbi[i]+1
          upb[i]=i2v(upb[i],scal[i],dig)
          fbondsok=False
          
    print(" ffun", menergylast," res:",mxarr, " opt: zoo, x0:",x0," gamma:",gamma,"cnt:",cnt,"min:",fminggx,fminggt,"conv:",fminncx,"boundok:",fbondsok)

#    update bounds     
    with open('bounds.dat','w') as ft:                                                                                                                                                        
                         
     for j in range(len(lob)):                                                                                                                                                                
                          
        print(lob[j],upb[j],file=ft)
        
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

