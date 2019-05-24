      module mymod 
        real, pointer :: work(:) 
        save work,val,index
!$omp   threadprivate(work,val,index) 
      end module mymod 

!###########################      
      subroutine sub1(n) 
      use mymod 
      use omp_lib
!$omp   parallel private(the_sum,i) 
        allocate(work(n)) 
        call sub2(the_sum) 
        i=omp_get_thread_num()
        write(*,*)"from sub1",i,the_sum 
!$omp   end parallel 
      end subroutine sub1 
!###########################  
    
      subroutine sub2(the_sum) 
        use mymod 
        use omp_lib
        work(:) = 10 
        index=omp_get_thread_num()
        the_sum=sum(work)
        work=work/(index+1)
        val=sum(work)
      end subroutine sub2 

!###########################      
      subroutine sub3(n) 
      use mymod 
!$omp   parallel
       write(*,*)"index=",index," val=",val," work=",work
!$omp   end parallel 
      end subroutine sub3 
!###########################      
      program a22_8_good 
        n = 4 
        call sub1(n) 
        write(*,*)"serial section"
        call sub3(n) 
      end program a22_8_good 


