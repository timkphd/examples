program do_vect
	use mpi
	integer myid, ierr,numprocs
	integer MPI_CHARLES
	integer, parameter:: b8 = selected_real_kind(14) ! DOUBLE_PRECISION
	! our Fortran data type
	type instance
		sequence
		! 3 MPI_DOUBLE_PRECISION
		real(b8)invert_rate,  mut_rate,    quit_value
		! 10 integers
		integer pop_size,     generations
		integer gene_size,    seed
		integer shift_rate,   shift_num
		integer global_rate,  stagnate
		integer hawk_rate,    hand_out
		! 2 logicals
		logical do_one,       the_top
	end type instance
	! types
	integer t(3)
	! counts
	integer b(3)
	! memory offset in bytes
	integer(KIND=MPI_ADDRESS_KIND) d(3)
	INTEGER(KIND=MPI_ADDRESS_KIND) a1,a2,a3
	! the data structure used to pass startup info to slaves
	type(instance) charles
	call MPI_INIT( mpi_err )
	call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
	call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )    
	
	! create a MPI data type used to pass startup data
! 3 types
	t(1)=MPI_DOUBLE_PRECISION
	t(2)=MPI_INTEGER
	t(3)=MPI_LOGICAL
	
! 3 doubles
	b(1)=3;
! 10 integers
	b(2)=10;
! two logicals
	b(3)=2

! offsets are in bytes from the 
! beginning of the data structure
	d(1)=0;
! offset space for 3 doubles
	d(2)=24;
! offset space for 3 doubles and 10 integers24+40
	d(3)=64
	! this would also work...
	CALL MPI_Get_address( charles%invert_rate, a1, ierr)
	CALL MPI_Get_address( charles%pop_size,    a2, ierr)
	CALL MPI_Get_address( charles%do_one,      a3, ierr)
	if(myid == 0) then
	 write(*,*)"we can use MPI_Get_address to find"
	 write(*,*)"offsets without knowing the sizes"
	 write(*,"(3i8)")0,a2-a1,a3-a1
	endif
	
	call MPI_Type_create_struct(3,b,d,t,MPI_CHARLES,mpi_err)
	call MPI_TYPE_COMMIT(MPI_CHARLES,mpi_err)
	if(myid == 0)then
		charles%invert_rate=0.12_b8
		charles%mut_rate=1.2_b8   
		charles%quit_value=12.0_b8
		charles%pop_size=999
		charles%generations=100
		charles%gene_size=799
		charles%seed=-1
		charles%shift_rate=20
		charles%shift_num=10
		charles%global_rate=5
		charles%stagnate=10
		charles%hawk_rate=20
		charles%hand_out=5
		charles%do_one=.false.
		charles%the_top=.true.
	endif
	if(myid == (0))write(*,"('sent ',3f7.2,10i4,2l4)")charles
	call MPI_BCAST(charles,1,MPI_CHARLES,0,MPI_COMM_WORLD,mpi_err)
	if(myid == (numprocs-1))write(*,"('got  ',3f7.2,10i4,2l4)")charles
	call MPI_Finalize(mpi_err)
end
