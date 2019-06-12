module dtime
use numz
real(b8) :: insert_t,test_t,invert_t
real(b8) :: dtime_1,dtime_2

contains
	subroutine dtime_init()
		insert_t=0
		test_t=0
		invert_t=0
	end subroutine
	subroutine dtime_report(ifile)
	    write(ifile,1234)test_t,insert_t,invert_t
	1234 format("test=",f10.2,"  insert=",f10.2,"  invert=",f10.2)
	end subroutine
end module
	
