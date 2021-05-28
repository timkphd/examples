import mpi.*;

class Hello {
    static public void main(String[] args) throws MPIException {
        int tag=1234;  // Tag for messages

	MPI.Init(args);

	int source=0;
    int destination;
    int tms[] = new int[1];
    int cnt[] = new int[1];
    int myrank = MPI.COMM_WORLD.getRank();
	int size = MPI.COMM_WORLD.getSize() ;
    String name=MPI.getProcessorName();
	System.out.println("Java Hello from " + name + " # " + myrank + " of "+size);
    if (myrank == source ){
        tms[0]=3;
        cnt[0]=4;
         if (args.length > 0) {tms[0]=Integer.parseInt(args[0]); }
         if (args.length > 1) {cnt[0]=Integer.parseInt(args[1]); }
    }
    MPI.COMM_WORLD.bcast(tms,1,MPI.INT, 0);
    MPI.COMM_WORLD.bcast(cnt,1,MPI.INT, 0);
    int count=cnt[0];
    int times=tms[0];
    for (int it=0; it < times ; it ++ ) {
        if (myrank == source ) {
          int message[] = new int [count];
          for (int i = 0; i < count; i++) {
              message[i]=i+it*1000;
           }
           for (destination=0; destination<size;destination++) {
            MPI.COMM_WORLD.send(message, count, MPI.INT, destination, tag);
           }
			System.out.print("Java processor "+myrank+" sent ");
          for (int i = 0; i < count; i++) {
             System.out.print(message[i]);
             System.out.print(" ");
             }
             System.out.println("");
          } 
        if (myrank != source ) {
          int message[] = new int [count];
          MPI.COMM_WORLD.recv(message, count, MPI.INT, 0, tag);
				System.out.print("Java processor "+myrank+"  got ");
          for (int i = 0; i < count; i++) {
             System.out.print(message[i]);
             System.out.print(" ");
             }
             System.out.println("");
          }
        }
        MPI.Finalize();
    }
}
