! Based on Pacheco, Peter S. Parallel Programming with MPI. San Francisco: Morgan Kaufmann, 1997.
module numz
   integer, parameter :: bx = selected_real_kind(12)
!        integer,parameter :: bx=selected_real_kind(4)
end module
!   linsolve.f
!   use scalapack and mpi to solve a system of linear equations
!   on a virtual rectangular grid of processes.
!
!   input:
!       n: order of linear system
!       nproc_rows: number of rows in process grid
!       nproc_cols: number of columns in process grid
!       row_block_size:  blocking size for matrix rows
!       col_block_size:  blocking size for matrix columns
!
!   output:
!       input data, error in solution, and time to solve system.
!
!   algorithm:
!     1.  initialize mpi and blacs.
!       2.  get process rank (my_rank) and total number of
!           processes (np).   use both blacs and mpi.
!       3a. process 0 read and broadcast matrix order (n),
!           number of process rows (nproc_rows), number
!           of process columns (nproc_cols), row_block_size,
!           and col_block_size.
!       3b. process != 0 receive same.
!       4.  use blacs_gridinit to set up process grid.
!       5.  compute amount of storage needed for local arrays.
!       6.  use scalapack routine descinit to initialize
!           descriptors for a, exact (= exact solution), and b.
!       7.  use random number generator to generate contents
!           of local block of matrix (a_local) or read from 
!           disk.
!       8.  set entries of exact to 1.0.
!       9.  generate b by computing b = a*exact.  use
!           pblas routine psgemv.
!      10.  solve linear system by call to scalapack routine
!           psgesv (solution returned in b).
!      11.  use pblas routines psaxpy and psnrm2 to compute
!           the norm of the error ||b - exact||_2.
!      12.  process 0 print results.
!      13.  free up storage, shutdown blacs and mpi.
!
!   notes:
!       1.  the vectors exact, and b are significant only
!           in the first process column.
!       2.  a_local is allocated as a linear array.
!       3.  the solver only allows square blocks.  so we
!           read in a single value, block_size, and assign
!           it to row_block_size and col_block_size.  thus,
!           since the matrix is square, nproc_rows = nproc_cols.
!
subroutine sendlog(l1,l2)
    use mpi
    logical l1,l2
    integer x1,x2
    integer ierror
    x1=0
    x2=0 
    if(l1)x1=1
    if(l2)x2=1   
    call mpi_bcast(x1, 1, mpi_integer, 0, mpi_comm_world, ierror)
    call mpi_bcast(x2, 1, mpi_integer, 0, mpi_comm_world, ierror)
    l1=(x1 == 1)
    l2=(x2 == 1)
end subroutine


program linsolve
   use numz
   use mpi
   implicit none
!
!   constants
   integer max_vector_size
   integer max_matrix_size
   integer descriptor_size
   parameter(max_vector_size=1000)
   parameter(max_matrix_size=250000)
   parameter(descriptor_size=10)
   real(bx) pwork(100000)
!
!   array variables
   real(bx) b_local(max_vector_size)
   integer b_descrip(descriptor_size)
!
   real(bx) exact_local(max_vector_size)
   integer exact_descrip(descriptor_size)
!
   real(bx) a_local(max_matrix_size)
   integer a_descrip(descriptor_size)
   integer pivot_list(max_vector_size)
!
!   scalar variables
   integer np
   integer my_rank
   integer nproc_rows, nproc_cols
   integer ierror
   integer m, n
   integer row_block_size, col_block_size
   integer blacs_context
   integer local_mat_rows, local_mat_cols
   integer exact_local_size
   integer b_local_size
   integer i, j
   integer my_process_row, my_process_col
   real(bx) error_2
   double precision start_time, elapsed_time
   real(bx) randout
   integer, allocatable ::  myseed(:)
   integer nseed
   integer numroc
   logical pr,nat_rand,l1,l2
!  fortran file output for printing arrays 
!  outnum 6 = stdout
!  anything other than 6 and a file will be created
   integer, parameter :: outnum=18
!
!   begin executable statements
!
!  default values for printing and reading
!  print arrays
   pr = .true.
! nat_rand create random a matrix
! if false read from file.
   nat_rand = .false.
!   initialize mpi
   call mpi_init(ierror)
   call mpi_comm_size(mpi_comm_world, np, ierror)
   call mpi_comm_rank(mpi_comm_world, my_rank, ierror)

!   get setup data
   if (my_rank .eq. 0) then
      read (5, *) n, nproc_rows, nproc_cols, row_block_size, col_block_size
      !read pr and nat_rand if available
      read(5,*,iostat=ierror)l1,l2
      if(ierror == 0 )then
          pr=l1
          nat_rand=l2
       endif
       if(pr)write(6,*)"saving data"
   end if
   call sendlog(pr,nat_rand)
   call mpi_bcast(n, 1, mpi_integer, 0, mpi_comm_world, ierror)
   call mpi_bcast(nproc_rows, 1, mpi_integer, 0, mpi_comm_world, ierror)
   call mpi_bcast(nproc_cols, 1, mpi_integer, 0, mpi_comm_world, ierror)
   call mpi_bcast(row_block_size, 1, mpi_integer, 0, mpi_comm_world, ierror)
   call mpi_bcast(col_block_size, 1, mpi_integer, 0, mpi_comm_world, ierror)

   if (np .lt. (nproc_rows*nproc_cols)) then
      write (6, "(' proc ', i2, ' > np = ', i2,        &
                  ', nproc_rows = ', i2,                 &
                  ', nproc_cols = ', i2)") my_rank, np, nproc_rows, nproc_cols
      write (6, "(' need more processes!  quitting.')")
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
   
   if (my_rank .eq. 0 .and. outnum .gt. 6 .and. pr) then
      open (unit=outnum, file="gesv.out", status="unknown")
   end if


!
!   the matrix is square
   m = n
!
!
!   build blacs grid.
   call blacs_get(0, 0, blacs_context)
!
!     'r': process grid will use row major ordering.
   call blacs_gridinit(blacs_context, 'row', nproc_rows, nproc_cols)
!
!
!   figure out how many rows and cols we'll need in the local
!     matrix.
   call blacs_pcoord(blacs_context, my_rank, my_process_row, my_process_col)
   local_mat_rows = numroc(m, row_block_size, my_process_row, 0, nproc_rows)
   local_mat_cols = numroc(n, col_block_size, my_process_col, 0, nproc_cols)
   if (local_mat_rows*local_mat_cols .gt. max_matrix_size) then
      write (6, "(' proc ', i2,                  &
                  ' > local_mat_rows = ', i5,   &
                  ', local_mat_cols = ', i5,    &
                  ', max_matrix_size = ', i6)") &
                       my_rank, local_mat_rows, local_mat_cols, max_matrix_size
      write (6, "(' insufficient storage!  quitting.')")
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
! now figure out storage for b_local and exact_local
   b_local_size = numroc(m, row_block_size, my_process_row, 0, nproc_rows)
   if (b_local_size .gt. max_vector_size) then
      write (6, "(' proc ', i2,                  &
                  ' > b_local_size = ', i5,     &
                  ', max_vector_size = ', i5)") &
                        my_rank, b_local_size, max_vector_size
      write (6, "(' insufficient storage!  quitting.')")
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
   exact_local_size = numroc(n, col_block_size, my_process_row, 0, nproc_rows)
   if (exact_local_size .gt. max_vector_size) then
      write (6, "(' proc ', i2,                  &
                  ' > exact_local_size = ', i5, &
                  ', max_vector_size = ', i5)") &
                       my_rank, exact_local_size, max_vector_size
      write (6, "(' insufficient storage!  quitting.')")
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
!
! now build the matrix descriptors
   call descinit(a_descrip, m, n, row_block_size, &
                 col_block_size, 0, 0, blacs_context, &
                 local_mat_rows, ierror)
   if (ierror .ne. 0) then
      write (6, "(' proc ', i2, ' > descinit for a failed, ierror = ', i3)") &
                 my_rank, ierror
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
   call descinit(b_descrip, m, 1, row_block_size, 1, &
                 0, 0, blacs_context, b_local_size,  &
                 ierror)
   if (ierror .ne. 0) then
      write (6, "(' proc ', i2, ' > descinit for b failed, ierror = ', i3)")  &
                 my_rank, ierror
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
   call descinit(exact_descrip, n, 1, col_block_size, 1, &
                 0, 0, blacs_context, exact_local_size,  &
                 ierror)
   if (ierror .ne. 0) then
      write (6, "(' proc > ', i2, ' > descinit for exact failed, ierror = ', i3)") &
                 my_rank, ierror
      call mpi_abort(mpi_comm_world, -1, ierror)
   end if
!
!
!   now initialize a_local and exact_local
   if (nat_rand) then
      if (my_rank .eq. 0) write (6, "(' random a')")
      call random_seed(size=nseed)
      allocate (myseed(nseed))
      myseed = my_rank + 10
      call random_seed(put=myseed)
      do j = 0, local_mat_cols - 1
         do  i = 1, local_mat_rows
            call random_number(randout)
            a_local(local_mat_rows*j + i) = randout
         enddo
      enddo
    else
! echo "800 800" > a
! grep aa gesv.dp | awk '{print $4}' >> a
! layout is as follows without a(*,*)=
!800 800
!a(1,1)=0.435675925118591323e+00
!a(2,1)=0.415248813315404419e+00
!...
!a(799,800)=0.566665140079333440e+00
!a(800,800)=0.650882145626408004e+00
      if (my_rank .eq. 0) write (6, "('reading a')")
        call pdlaread("a", a_local, a_descrip, 0, 0, pwork)
    end if
    if (pr) call pdlaprnt(n, n, a_local, 1, 1, a_descrip, 0, 0, "aaaaa", outnum, pwork)
    do  i = 1, exact_local_size
        exact_local(i) = 1.0_bx
    enddo
!
!
!   use pblas function psgemv to compute right-hand side b = a*exact
!     'n': multiply by a -- not a^t or a^h
               call pdgemv('n', m, n, 1.0_bx, a_local, 1, 1, a_descrip, &
                           exact_local, 1, 1, exact_descrip, 1, 0.0_bx, &
                           b_local, 1, 1, b_descrip, 1)
               if (pr) call pdlaprnt(n, 1, b_local, 1, 1, b_descrip, 0, 0, "bbbbb", outnum, pwork)
               if (pr) call pdlaprnt(n, 1, exact_local, 1, 1, b_descrip, 0, 0, "xxxxx", outnum, pwork)
!
!
!   done with setup!  solve the system.
               call mpi_barrier(mpi_comm_world, ierror)
               start_time = mpi_wtime()
               call pdgesv(n, 1, a_local, 1, 1, a_descrip, pivot_list, &
                           b_local, 1, 1, b_descrip, ierror)
               elapsed_time = mpi_wtime() - start_time
               if (ierror .ne. 0) then
                  write (6, "(' proc ', i2, ' > psgesv failed, ierror = ', i3)") my_rank, ierror
                  call mpi_abort(mpi_comm_world, -1, ierror)
               end if
!      write(6,850) my_rank, (b_local(j), j = 1, b_local_size)
!  850   format(' ','proc ',i2,' > b = ',f6.3,' ',f6.3,' ',f6.3,' ', &
!              f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ', &
!              f6.3)
!      write(6,860) my_rank, (exact_local(i), i = 1, exact_local_size)
!  860   format(' ','proc ',i2,' > exact = ',f6.3,' ',f6.3,' ',f6.3,' ', &
!              f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ',f6.3,' ', &
!              f6.3)

!   now find the norm of the error.
!     first compute exact = -1*b + exact
               call pdaxpy(n, -1.0_bx, b_local, 1, 1, b_descrip, 1, &
                           exact_local, 1, 1, exact_descrip, 1)
!     now compute 2-norm of exact
               call pdnrm2(n, error_2, exact_local, 1, 1, exact_descrip, 1)
!
               if (pr) call pdlaprnt(n, 1, b_local, 1, 1, b_descrip, 0, 0, "bbbbb", outnum, pwork)
               !write(my_rank+10,"(10f10.0)")b_local
               if (my_rank .eq. 0) then
                  write (6, "(' n = ', i4, ', number of processes = ', i2)") n, np
                  write (6, "(' process rows = ', i2, ', process cols = ', i2)") nproc_rows, nproc_cols
                  write (6, "(' row block size = ', i3, ', col block size = ', i3)") row_block_size, col_block_size
                  write (6, "(' 2-norm of error = ', e13.6)") error_2
                  write (6, "(' elapsed time = ', d13.6, ' milliseconds')") 1000.0*elapsed_time
               end if

!   now free up allocated resources and shut down
!     call blacs_exit.  argument != 0 says, "i'll shut down mpi."
               call blacs_exit(1)
               call mpi_finalize(ierror)
!
               stop
!
!     end of main program linsolve
            end

