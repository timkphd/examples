PROGRAM test_getenv
  include "mpif.h"
  CHARACTER(len=255) :: homedir
  CHARACTER(len=255) :: SLURM_JOB_ID
  CHARACTER(len=255) :: SLURM_ARRAY_JOB_ID
  CHARACTER(len=255) :: SLURM_ARRAY_TASK_ID
  CHARACTER(len=64)  :: ARG 
  CHARACTER(len=10)  :: tstr
  call date_and_time(time=tstr)
      myid=0
      numprocs=0
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
  write(*,*)myid," of ",numprocs

!## SLURM_JOB_ID and SLURM_ARRAY_TASK_ID changes for each element in the array
!## SLURM_ARRAY_TASK_ID will be set to the job array index value
!## SLURM_ARRAY_JOB_ID will be set to the first job ID of the array


  CALL get_environment_variable("HOME", homedir)
  CALL get_environment_variable("SLURM_JOB_ID", SLURM_JOB_ID)
  if(len_trim(SLURM_JOB_ID) < 1)SLURM_JOB_ID="SLURM_JOB_ID"

  CALL get_environment_variable("SLURM_ARRAY_JOB_ID", SLURM_ARRAY_JOB_ID)
  if(len_trim(SLURM_ARRAY_JOB_ID) < 1)SLURM_ARRAY_JOB_ID="SLURM_ARRAY_JOB_ID"

  CALL get_environment_variable("SLURM_ARRAY_TASK_ID", SLURM_ARRAY_TASK_ID)
  if(len_trim(SLURM_ARRAY_TASK_ID) < 1)SLURM_ARRAY_TASK_ID="SLURM_ARRAY_TASK_ID"

  WRITE (*,*)TRIM(tstr)," ",trim(SLURM_JOB_ID), " ",&
             trim(SLURM_ARRAY_JOB_ID)," ",trim(SLURM_ARRAY_TASK_ID)
  if( myid == 0)then
          i = 0
  do
    call get_command_argument(i, arg)
    if (len_trim(arg) == 0) exit

    write (*,*)"command line argument ",i," = ",trim(arg)
    i = i+1
  end do
 endif
      call MPI_FINALIZE(ierr)

END PROGRAM

