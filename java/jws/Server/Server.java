// This example is from the book _Java in a Nutshell_ by David Flanagan.
// Written by David Flanagan.  Copyright (c) 1996 O'Reilly & Associates.
// You may study, use, modify, and distribute this example for any purpose.
// This example is provided WITHOUT WARRANTY either expressed or implied.

import java.io.*;
import java.net.*;


public class Server extends Thread {
    public final static int DEFAULT_PORT = 6789;
    protected int port;
    protected ServerSocket listen_socket;
    
    // Exit with an error message, when an exception occurs.
    public static void fail(Exception e, String msg) {
        System.err.println(msg + ": " +  e);
        System.exit(1);
    }
    
    // Create a ServerSocket to listen for connections on;  start the thread.
    public Server(int port) {
        if (port == 0) port = DEFAULT_PORT;
        this.port = port;
        try { listen_socket = new ServerSocket(port); }
        catch (IOException e) { fail(e, "Exception creating server socket"); }
        System.out.println("Server: listening on port " + port);
        this.start();
    }
    
    // The body of the server thread.  Loop forever, listening for and
    // accepting connections from clients.  For each connection, 
    // create a Connection object to handle communication through the
    // new Socket.
    public void run() {
        try {
            while(true) {
                Socket client_socket = listen_socket.accept();
                Connection c = new Connection(client_socket);
            }
        }
        catch (IOException e) { 
            fail(e, "Exception while listening for connections");
        }
    }
    
    // Start the server up, listening on an optionally specified port
    public static void main(String[] args) {
        int port = 0;
        if (args.length == 1) {
            try { port = Integer.parseInt(args[0]);  }
            catch (NumberFormatException e) { port = 0; }
        }
        new Server(port);
    }
}

// This class is the thread that handles all communication with a client
class Connection extends Thread {
    protected Socket client;
    protected DataInputStream in;
    protected PrintStream out;

    // Initialize the streams and start the thread
    public Connection(Socket client_socket) {
        client = client_socket;
        try { 
            in = new DataInputStream(client.getInputStream());
            out = new PrintStream(client.getOutputStream());
        }
        catch (IOException e) {
            try { client.close(); } catch (IOException e2) { ; }
            System.err.println("Exception while getting socket streams: " + e);
            return;
        }
        this.start();
    }
    
    // Provide the service.
    // Read a line, reverse it, send it back.  
    public void run() {
        String line;
        StringBuffer revline;
        int len;
        try {
            for(;;) {
                // read in a line
                line = in.readLine();
		System.out.println(line);
		Runtime rt = Runtime.getRuntime();
		Process prcs =rt.exec("/home/od/tkaiser/bin/running xterm");
		DataInputStream d = new DataInputStream(prcs.getInputStream());
		String aline;
		while((aline =d.readLine()) != null)
		    System.out.println(aline);
		if (line == null) break;
                // reverse it
                len = line.length();
                revline = new StringBuffer(len);
                for(int i = len-1; i >= 0; i--) 
                    revline.insert(len-1-i, line.charAt(i));
                // and write out the reversed line
                out.println(revline);
            }
        }
        catch (IOException e) { ; }
        finally { try {client.close();} catch (IOException e2) {;} }
    }
}
