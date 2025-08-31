# DGBO

DGBO: Discrete Global Basis-set optimization
by Fabio Della Sala, Summer 2025, PRIN AC^3


The dgbo program will optimize the crystal basis-set, searching for a global minimum, on a discrete grid, without derivatives.
(only optimization of exponents of uncontracted shell is currently supported)


The program must be in the ~/DGBO directory

------------------------------------------------------
To install the program:

     cd DGBO
     sh ./install
-------------------------------------------------------
EXAMPLE: lithium bulk, optimizing three P-shells:
In this example there are two local minima

     -7.4558253192  res:  3.0   0.4  0.1 
     -7.4579874517  res:  6.0   0.8  0.08
The second is the global one.
To run the DGBO program with 1 digit accuracy:

     cd Li3
     export GMF="%2.0E"
     ~/DGBO/dgbo | tee dgbo.out

The input file in the directory is only

      inputhf.d12.orig

It is a stardard crystal file, with * where exponent have to be optimized
(only exponents of uncontracted shell are supported)
This file is also used for the starting point.

To consider a second ( a third, ... )  starting point use

       inputhf.d12.orig2
       (inputhf.d12.orig3)

and dgbo will run from all these starting point.
In the Li3 example three different starting points are used:

         2 1 0.2
         3.31 0.5488 0.106 
         3 0.4 0.1
and dgbo always go to the global minimum.

The main results for the optimization can be easi visualized using the command:

     grep res: dgbo.out

with results:

     enerefzero  -7.44947518180000000000 res:
     fun  -7.4494751818  res:  [2, 10, 11]
      fun -7.4579874517  res:  [6.   0.8  0.08]  opt: zoo , x0: [2.  1.  0.2]  gamma: 0 cnt: 450 min: 3 3 conv: 0 boundok: True
      ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [2.  1.  0.2]  gamma: 0 cnt: 451 min: 3 3 conv: 0 boundok: True
     origene  -7.45164345730000000000 res:
     fun  -7.4484632856  res:  [3, 5, 10]
      fun -7.4579874517  res:  [6.   0.8  0.08]  opt: zoo , x0: [3.31   0.5488 0.106 ]  gamma: 0 cnt: 542 min: 3 3 conv: 0 boundok: True
      ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [3.31   0.5488 0.106 ]  gamma: 0 cnt: 543 min: 3 3 conv: 0 boundok: True
     origene  -7.45582531920000000000 res:
     fun  -7.4558253192  res:  [3, 4, 10]
      fun -7.4579874517  res:  [6.   0.8  0.08]  opt: zoo , x0: [3.  0.4 0.1]  gamma: 0 cnt: 542 min: 3 3 conv: 0 boundok: True
      ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [3.  0.4 0.1]  gamma: 0 cnt: 543 min: 3 3 conv: 0 boundok: True


As you can see there are three group of solution (as there are three orig* files)
The first fun is the starting point
the second fun is the optimzed solution
the third ffun is an additional check to verify that it is a local miminum
   min: 3 3 indicates that is it the minimum for 3 direction over 3
   conv: 0 indicates that it is converged solution (i.e. closest point are also SCF converged)
enerefzero (origene) at the beginning is the energy of the first orig file, without discrete-integer approximation (i.e. with exponent with all digits)

cnt is the number of times crystal calculations have been called
However, DGBO, saves on disk all the crystal calculations, thus the real number of cystal calculation can be obtained from:

        sort -k 1 -g -r basrun.allene.0.dat  | uniq | wc
to be compared with the full dimensional space

        grep allsize dgbo.out | tail -n 1
   
Together with a starting point, dgbo also define the bound interval for the exponents, with
an algortitm which depends on the starting point itself.
Even if the program try to enlarge the bounds if the final solution is at the bounds, 
it can happen that different starting point gives different global minimum
because the bounds are different.
To use an external bound file, create the 'bounds_ext.dat' file

-------------------------------------------------------------

dgbo also create many log files

     basderfol.0.log
     basdergmf.0.log
     basrun.0.log

where 0 is the gamma parameter

---------------------------------------------------
GMF is a REQUIRED (!!!) enviroment variable

1-digit accuracy is for a first guess of exponent

for 2-digits accuracy

       export GMF="%3.1E"

this gives accurate exponents

for 3-digits accuracy

      export GMF="%4.2E"

this is usually not required as the energy changes will be usually close to TOLDEE

for 4-digits accuracy

 export GMF="%5.3E"

this is for reference

----------------------------------------------------

DISCRETE DESCENT ALGORTIM

You can also do a discrete descent run using

      cd Li3
       export GMF="%2.0E"
       ~/DGBO/basderfol.sh 10
       
the starting point is specified in the file basrunsed.dat, and the paramter (10) specify
a multiplicator for the convergence (e.g TOLDEE=1.d-7 *10 = 1.d-6)
Using the first starting point ,i.e.

        PAR1P 2.000000
        PAR2P 1.000000
        PAR3P 0.200000
        
we obtain another local minima

       cycle=  0 energy=  -7.44947518180000000000
       2 1E-01 -0.0013940100
       cycle=  1 energy=  -7.45086919260000000000
       1 9E-01 -0.0001524480
       cycle=  2 energy=  -7.45102164020000000000
       1 8E-01 -0.0001666230
       cycle=  3 energy=  -7.45118826360000000000
       0 3E+00 -0.0000620233 
       cycle=  4 energy=  -7.45125028690000000000
       1 7E-01 -0.0001745050
       cycle=  5 energy=  -7.45142479210000000000
       0 4E+00 -0.0000455558
      energy: -7.45142479210000000000 dstr: [4E+00 7E-01 1E-01 ]



---------------------------------------------------------
to increase the accuracy you can run

       ~/DGBO/increaseacc.sh  "%3.1E" | tee INC/dgbo.out 
in the directory where the "%2.0E" results are done
In this way in the INC subdirectory you will start from the previous solution and increase the accuracy

or you can also do

     export GMF="%3.1E"
     mkdir basfol
     cp inputhf.d12.par basfol
     cp sedfile.dat     basfol/basrunsed.dat
     cd basfol
     ~/DGBO/basderfol.sh
---------------------------------------------------------
OPTIONS FILES:

            gamma.info 
            
this file contain the gamma parameter
If not preset is zero
the value of gamma can be obtained (after a run without gamma)  with the script fgamma.sh
             
            maxrmax.info  
             
this file contains the maximum rmax values (eigmax/eigmin)
if not present is 10000


             bmax.dat
this file contains the maximum exponents for each parameter.
if it is zero it is not considered.
it is not zero for shells with a tighter contraction.
this file is generated by crybasrun.sh
this file is used by ALL program in the DGBO directory.

             bounds.dat
this file contains the bounds for the exponents for each parameter, i.e. the min and the maximum value.
this file is generated by crybasrun.sh
The bounds.dat file is used by the zoo pyhton program.
The max value can be negative: this means that it is fixed to its absolute value.
This matches the data in the bmax.dat file

              
change the function runcry in basuty.sh to change how crystal is lauched
(by default runcry23OMP)

------------------------------------------------------------
CONSTRAINTS:
 DGBO search for a global minima with the following constratints:
 i) the exponents have to be a ratio larger than 1.618 (golden radius)
 ii) rmax must be smaller than 10000 (or rmax.info)
 iii) all simulations with DIIS error larger than 9*TOLDEE are considerd NOTCONVERGED

-----------------
IMPORTANT OUTPUT FILE

basrun.allene.dat: format
 energy energycond conddiff listofexponenet


basrun.log: a log file with all details

for EACH simulations:


out.*          : crystal output file
out.*.eig      : crystal output file for the EIG RUN
out.*.ene      : energy
out.*.eig.rmax : rmax value

----------------------
VERSION:

       opt3zoo.py : original    
       opt4zoo.py : supports downto python3.5 and ivvi.py
       opt5zoo.py : supports negative(i.e. fixed) bounds
 
-----------integer coding-------------
the exponent, floating numbers, are coded into integer in a logarithm fashion:

1-digit, scal=1E-3

     1 => 1E-3
     2 => 2E-3     
     ..
     9 => 9E-3
     10 => 1E-2
     11 => 2E-2
     ..
     18 => 9E-2

2-digit2, scal=1E-3

     10 => 1.0E-3
     11 => 1.1E-3
     ...
     99 => 9.9E-3
     100 => 1.0E-2
     101 => 1.1E-2
     ..
     189 => 9.9E-2
     
