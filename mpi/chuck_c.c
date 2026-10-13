/*
Shows how to use MPI_Type_vector to send noncontiguous blocks of data
 and MPI_Get_count and MPI_Get_elements to see the number of elements sent
*/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <stdbool.h>

    MPI_Datatype MPI_CHARLES;
	struct instance {
		// 3 MPI_DOUBLE_PRECISION
		double invert_rate,  mut_rate,    quit_value;
		// 10 integers
		int pop_size,        generations;
		int gene_size,       seed;
		int shift_rate,      shift_num;
		int global_rate,     stagnate;
		int hawk_rate,       hand_out;
		// 2 logicals
		bool do_one,         the_top;
	};
void doprint(char *where, struct instance charles) {
    printf("%s ",where);
	printf("%6.2f %6.2f %6.2f",charles.invert_rate,charles.mut_rate,charles.quit_value);
	printf("%4d%4d%4d%4d%4d",charles.pop_size,   charles.generations,
	                         charles.gene_size,  charles.seed,         charles.shift_rate);
	printf(" %4d%4d%4d%4d%4d",charles.shift_num,  charles.global_rate,
	                         charles.stagnate,   charles.hawk_rate,    charles.hand_out);
	printf(" %4d%4d\n",charles.do_one,   charles.the_top);                        
}
int main(int argc, char **argv ,char **envp)
{
    int myid, numprocs,mpi_err;
    MPI_Datatype MPI_LEFT_RITE;
    MPI_Status status;
	struct instance charles;
	MPI_Aint array_of_displacements[3];
	MPI_Aint a1,a2,a3;
	MPI_Datatype array_of_types[3];
	int b[3];
	MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);

// our types
	array_of_types[0]=MPI_DOUBLE;
	array_of_types[1]=MPI_INT;
	array_of_types[2]=MPI_LOGICAL;

// 3 doubles
	b[0]=3;
// 10 integers
	b[1]=10;
// two logicals
	b[2]=2;

// Set up our displacements
// start of array
	array_of_displacements[0]=0;
// offset for 3 doubles
	array_of_displacements[1]=24;
// offset for 3 doubles + 10 integers
	array_of_displacements[2]=64;
    

    MPI_Get_address( &charles.invert_rate, &a1);
    MPI_Get_address( &charles.pop_size, &a2);
    MPI_Get_address( &charles.do_one, &a3);
    if(myid == 0){
      printf("we can use MPI_Get_address to find\n");
      printf("offsets without knowing the sizes\n");
      printf("%ld %ld %ld\n",0,a2-a1,a3-a1);
    }
    MPI_Type_create_struct(3,b,array_of_displacements,array_of_types,&MPI_CHARLES);
    if(myid == 0){
		charles.invert_rate=0.12d;
		charles.mut_rate=1.2d   ;
		charles.quit_value=12.0d;
		charles.pop_size=999;
		charles.generations=100;
		charles.gene_size=799;
		charles.seed=-1;
		charles.shift_rate=20;
		charles.shift_num=10;
		charles.global_rate=5;
		charles.stagnate=10;
		charles.hawk_rate=20;
		charles.hand_out=5;
		charles.do_one=1;
		charles.the_top=0;
	}
	MPI_Type_commit(&MPI_CHARLES);
	if(myid == 0) doprint("sent ",charles);

	MPI_Bcast(&charles,1,MPI_CHARLES,0,MPI_COMM_WORLD);
	if(myid == (numprocs-1)) doprint(" got ",charles);

	MPI_Finalize();


}


