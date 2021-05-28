import mpi.*;
// Intel version of Java MPI.  
// API differs from the OpenMPI version
// To get information:
//   jar xf /nopt/nrel/apps/compilers/intel/2020.1.217/compilers_and_libraries_2020.1.217/linux/mpi/intel64/lib/mpi.jar
//   cd mpi
//   for x in `ls` ; do javap $x ; done
//   https://software.intel.com/content/www/us/en/develop/documentation/mpi-developer-guide-linux/top/running-applications/java-mpi-applications-support.html
//   https://software.intel.com/content/www/us/en/develop/documentation/mpi-developer-reference-linux/top/miscellaneous/java-bindings-for-mpi-2-routines.html
class Ihello {
	static public void main(String[] args) throws MPIException {
		int tag=50;  // Tag for messages

		MPI.Init(args);

		mpi.Comm  comm = mpi.Comm.WORLD;
		int myrank = comm.getRank();
		int size = comm.getSize();
		
		int tosend=10;
	        int toget=10;

		System.out.println("Hello world from rank " + myrank + " of " + size);
		if (myrank == 0 ) {
			int message[] = new int [10];
			for (int i = 0; i < 10; i++) {
				message[i]=i;
			}
			mpi.PTP.send(message,10,mpi.Datatype.INT,1,tag,comm);
		} 
		if (myrank == 1 ) {
			int message[] = new int [10];
			mpi.PTP.recv(message,10,mpi.Datatype.INT,0,tag,comm);
			for (int i = 0; i < toget; i++) {
				System.out.println(message[i]);
			}
		}
		System.out.println("done  " + myrank + " of " + size);
		MPI.Finalize();
	}
}
