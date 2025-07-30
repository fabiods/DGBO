# DGBO

DGBO: Discrete Global Basis-set optimization
by Fabio Della Sala, Summer 2025, PRIN AC^3


The dgbo program will optimize the crystal basis-set, searching for a global minimum, on a discrete grid, without derivatives.
(only optimization of exponents of uncontracted shell is currently supported)


The program must be in the ~/DGBO directory

------------------------------------------------------
To install the program:

     cd DGBO
     ./install
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
       (input.d12.orig3)

and dgbo will run from all these starting point.
In the Li3 example three different starting points are used:

         2 1 0.2
         3.31 0.5488 0.106 
         3 0.4 0.1
and dgbo always go to the global minimum:
          grep res: dgbo.out | grep ffun
          ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [2.  1.  0.2]           gamma: 0 cnt: 1215 min: 3 3 conv: 0 boundok: True
          ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [3.31   0.5488 0.106 ]  gamma: 0 cnt: 1725 min: 3 3 conv: 0 boundok: True
          ffun -7.4579874517  res: [6.   0.8  0.08]  opt: zoo, x0: [3.  0.4 0.1]           gamma: 0 cnt: 1759 min: 3 3 conv: 0 boundok: True


Together with a starting point, dgbo also define the bound interval for the exponents, with
an algortitm which depends on the starting point itself.
Even if the program try to enlarge the bounds if the final solution is at the bounds, 
it can happen that different starting point gives different global minimum
because the bounds are different.
To use an external bound file, create the 'bounds_ext.dat' file


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
      cd Li3
      export GMF="%2.0E"


---------------------------------------------------------
OPTIONS:

gamma.info : this file contain the gamma parameter
             If not preset is zero

rmax.info  : this file contains the maximum rmax values (eigmax/eigmin)
             if not present is 10000


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
