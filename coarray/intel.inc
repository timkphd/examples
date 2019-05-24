#INTEL
FORT=ifort
FOPT= -coarray=distributed 
FOPT= -coarray=shared -coarray-num-images=8
ENVFILE=intelenv.f90
#ENVFILE=dummyenv.f90

