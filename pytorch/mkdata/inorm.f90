program doit
 real aline(784)
 integer*1 iline(784)
 character cline(784)

 
 open(88,file='rcsout.bin',status='old',FORM='UNFORMATTED',access='stream')
 open(37,file='rcsout.norm',status='new',FORM='UNFORMATTED',access='stream')

 do i=1,70000
   read(88,end=1234)aline
   x1=minval(aline)
   x2=maxval(aline)
y1=0.0
y2=255.1
a=(y2-y1)/(x2-x1)
b=y1-a*x1
   aline=aline*a+b
   iline=aline
   write(37)iline
   write(*,"(i4)")iline
 enddo
 1234 write(*,*)i-1
 end program
 
 