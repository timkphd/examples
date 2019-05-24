      module a22_module8 
        type thefit
          sequence
          real val
          integer index
        end type thefit
      end module a22_module8 
!###########################      
      subroutine sub1(n) 
      use a22_module8 
        real, pointer :: work(:) 
        type(thefit) bonk
        common /mycom/ work,bonk 
!$omp   threadprivate(/mycom/) 

!$omp   parallel private(the_sum) 
        allocate(work(n)) 
        call sub2(the_sum) 
       write(*,*)the_sum 
!$omp   end parallel 
      end subroutine sub1 
!###########################      
      subroutine sub2(the_sum) 
        use a22_module8 
        use omp_lib
        real, pointer :: work(:) 
        type(thefit) bonk
        common /mycom/ work,bonk 
!$omp   threadprivate(/mycom/) 
        work(:) = 10 
        bonk%index=omp_get_thread_num()
        the_sum=sum(work)
        work=work/(bonk%index+1)
        bonk%val=sum(work)
      end subroutine sub2 
!###########################      
      subroutine sub3(n) 
      use a22_module8 
        real, pointer :: work(:) 
        type(thefit) bonk
        common /mycom/ work,bonk 
!$omp   threadprivate(/mycom/) 
!$omp   parallel
       write(*,*)"bonk=",bonk%index,work,bonk%val
!$omp   end parallel 
      end subroutine sub3 
!###########################      
      program a22_8_good 
        use a22_module8
        real, pointer :: work(:) 
        type(thefit) bonk
        common /mycom/ work,bonk 
!$omp   threadprivate(/mycom/) 
        n = 10 
        call sub1(n) 
        write(*,*)"serial section"
        call sub3(n) 
      end program a22_8_good 


