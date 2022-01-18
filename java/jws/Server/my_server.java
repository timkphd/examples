// This example is from the book _Java in a Nutshell_ by David Flanagan.
// Written by David Flanagan.  Copyright (c) 1996 O'Reilly & Associates.
// You may study, use, modify, and distribute this example for any purpose.
// This example is provided WITHOUT WARRANTY either expressed or implied.

import java.io.*;
import java.net.*;

public class my_server {

    /**
     * Constructor.
     */
    public my_server () {
    }

    public static void main(String args[]) {
    
	Server my_server;
	System.out.println("Hello from server code");
	my_server=new Server(0);
	
    }
}


