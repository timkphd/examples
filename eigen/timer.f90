module timeit
    contains
function atime(ftime)
real*8 atime
real*8, optional :: ftime
real*8 t1,t2
integer count,count_rate,count_max
real*8 c,cr,cm
  call system_clock(count,count_rate,count_max)
  c=count
  cr=count_rate
  cm=count_max
  t1=c/cr
  if(present(ftime))then
     atime=t1-ftime
     if(atime .le. 0.0)atime=atime+cm/cr
  else
     atime=t1
  endif
end function
end module


     
  