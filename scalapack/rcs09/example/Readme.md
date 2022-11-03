### Intel MKL Libraries

These are examples of using the Intel MKL library.

In particular the programs call the routine cgesv
to solve the equations A*X = B for complex values.

mkl.c and mkl.f90 are simple examples with built in data.

The program "fourd.f90  implements the scattering equations 
described in J. H. Richmond, "Scattering by a Dielectric Cylinder 
of Arbitrary Cross Section Shape." IEEE Trans. on Antennas and 
Propagation, vol AP-13, pp 334-341, May 1965.  The output of 
this program, out.dat, is a field strength around the dielectric 
cylinder as a function of angle.  That is, it (more or less) calculates
the radar cross section (RCS). The input shape is a wing.


To build and run...

```
source /nopt/nrel/apps/210929a/myenv.2110041605
module purge
module load intel-oneapi-compilers
module load intel-oneapi-mkl
module load gcc

make clean
make
make run
```

Example output:

```

./mklc
 CGESV Example Program Results

 Solution
 ( -1.09, -0.18) (  1.28,  1.21)
 (  0.97,  0.52) ( -0.22, -0.97)
 ( -0.20,  0.19) (  0.53,  1.36)
 ( -0.59,  0.92) (  2.22, -1.00)

 Details of LU factorization
 ( -4.30, -7.10) ( -6.47,  2.52) ( -6.51, -2.67) ( -5.86,  7.38)
 (  0.49,  0.47) ( 12.26, -3.57) ( -7.87, -0.49) ( -0.98,  6.71)
 (  0.25, -0.15) ( -0.60, -0.37) (-11.70, -4.64) ( -1.35,  1.38)
 ( -0.83, -0.32) (  0.05,  0.58) (  0.93, -0.50) (  2.66,  7.86)

 Pivot indices
      3      3      3      4
./mklf
 CGESV Example Program Results
 
 Solution
 ( -1.09, -0.18) (  1.28,  1.21)
 (  0.97,  0.52) ( -0.22, -0.97)
 ( -0.20,  0.19) (  0.53,  1.36)
 ( -0.59,  0.92) (  2.22, -1.00)
 
 Details of LU factorization
 ( -4.30, -7.10) ( -6.47,  2.52) ( -6.51, -2.67) ( -5.86,  7.38)
 (  0.49,  0.47) ( 12.26, -3.57) ( -7.87, -0.49) ( -0.98,  6.71)
 (  0.25, -0.15) ( -0.60, -0.37) (-11.70, -4.64) ( -1.35,  1.38)
 ( -0.83, -0.32) (  0.05,  0.58) (  0.93, -0.50) (  2.66,  7.86)
 
 Pivot indices
      3      3      3      4
./fourd.mkl
  matrix generated  0.856000002473593       of size         3999
 beam=   94.26364       94.76364       95.26363    
        3999  did solve  0.752000000327826          using :cgesv     
 matrix generation time  0.856000002473593     
 matrix solve time   0.752000000327826     
 total computaion time    1.79600000008941     
    
```

