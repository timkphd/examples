/*
 * Copyright (c) 2011      Cisco Systems, Inc.  All rights reserved.
 *
 * Simple ring test program
 */

import mpi.* ;
import ex.Util;

// el1:java> debug
// r1i7n35:java> ml openmpi/4.1.0-gcc-8.4.0/gcc-8.4.0
// r1i7n35:java> make clean
// r1i7n35:java> make
// r1i7n35:java> mpirun -n 4 java -Djava.library.path=/home/tkaiser2/examples/java Ring.java 
class Ring {
    static public void main(String[] args) throws MPIException {


	MPI.Init(args) ;

	int source;  // Rank of sender
	int dest;    // Rank of receiver
	int tag=50;  // Tag for messages
	int next;
	int prev;
	int message[] = new int [1];

	int myrank = MPI.COMM_WORLD.getRank() ;
	int size = MPI.COMM_WORLD.getSize() ;
        long t1=System.nanoTime();
        System.out.println("core: "+Util.getCore());

	/* Calculate the rank of the next process in the ring.  Use the
	   modulus operator so that the last process "wraps around" to
	   rank zero. */

	next = (myrank + 1) % size;
	prev = (myrank + size - 1) % size;

	/* If we are the "master" process (i.e., MPI_COMM_WORLD rank 0),
	   put the number of times to go around the ring in the
	   message. */

	if (0 == myrank) {
	    message[0] = 10;

	    //System.out.println("Process 0 sending " + message[0] + " to rank " + next + " (" + size + " processes in ring)");
	    MPI.COMM_WORLD.send(message, 1, MPI.INT, next, tag);
	}

	/* Pass the message around the ring.  The exit mechanism works as
	   follows: the message (a positive integer) is passed around the
	   ring.  Each time it passes rank 0, it is decremented.  When
	   each processes receives a message containing a 0 value, it
	   passes the message on to the next process and then quits.  By
	   passing the 0 message first, every process gets the 0 message
	   and can quit normally. */

	while (true) {
	    MPI.COMM_WORLD.recv(message, 1, MPI.INT, prev, tag);

	    if (0 == myrank) {
                long t2=System.nanoTime();
                if ((t2-t1)/1e9 > 10 ) {
                 message[0]=0;
                }
		//System.out.println("Process 0 decremented value: " + message[0]);
	    }

	    MPI.COMM_WORLD.send(message, 1, MPI.INT, next, tag);
	    if (0 == message[0]) {
		System.out.println("core "+Util.getCore()+" Process " + myrank + " exiting ");
		break;
	    }
	}

	/* The last process does one extra send to process 0, which needs
	   to be received before the program can exit */

	if (0 == myrank) {
	    MPI.COMM_WORLD.recv(message, 1, MPI.INT, prev, tag);
	}

	MPI.Finalize();
    }
}
