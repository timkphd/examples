import mpi.*;

class Hello {
    static public void main(String[] args) throws MPIException {
        int tag=50;  // Tag for messages

	MPI.Init(args);

	int myrank = MPI.COMM_WORLD.getRank();
	int size = MPI.COMM_WORLD.getSize() ;
        int tosend=10;
        int toget=10;
	System.out.println("Hello world from rank " + myrank + " of " + size);
        if (myrank == 0 ) {
          int message[] = new int [10];
          for (int i = 0; i < 10; i++) {
              message[i]=i;
           }
           MPI.COMM_WORLD.send(message, tosend, MPI.INT, 1, tag);
          } 
        if (myrank == 1 ) {
          int message[] = new int [5];
          MPI.COMM_WORLD.recv(message, toget, MPI.INT, 0, tag);
          for (int i = 0; i < toget; i++) {
             System.out.println(message[i]);
             }
          }
	System.out.println("done  " + myrank + " of " + size);
        MPI.Finalize();
    }
}
