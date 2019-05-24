import random
def doit(t):
    rmin=-0.5*t
    rmax=1.5*t
    dr=rmax-rmin
    x=random.random()
    min=x*dr+rmin
    x=random.random()
    max=x*dr+rmin
    if max < min:
            tmp=min
            min=max
            max=tmp
    x=random.random()
    amp=10.0*x
    x=random.random()
    f=5000*x
    x=random.random()
    ic=0
    if x < 1.0/3.0:
            ic=-1
    if x > 1.0/3.0:
            ic=0
    if x > 2.0/3.0:
            ic=1
    return [min,max,amp,f,ic]
imax=50
print imax-1
mytop=900
for i in range(1,imax):
	z=doit(mytop)
	print "%10.2f %10.2f  %10.2f %10.2f %4d" % (z[0],z[1],z[2],z[3],z[4])
print 0.0001,mytop
