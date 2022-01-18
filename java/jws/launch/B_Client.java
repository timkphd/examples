import java.io.*;
import java.net.*;


public class B_Client {
    public static final int DEFAULT_PORT = 6789;
    private DataInputStream sin=null;
    private PrintStream sout=null;
    private Socket s = null;
    public static void usage() {
        System.out.println("Usage: my_client=new B_Client <hostname> [<port>]");
        System.exit(0);
    } 
    public B_Client() { usage();}   
	public B_Client(String[] args) {
        int port = DEFAULT_PORT;
        
        // Parse the port specification
        if ((args.length != 1) && (args.length != 2)) usage();
        if (args.length == 1) port = DEFAULT_PORT;
        else {
            try { port = Integer.parseInt(args[1]); }
            catch (NumberFormatException e) { usage(); }
        }
        
        try {
            // Create a socket to communicate to the specified host and port
            s = new Socket(args[0], port);
            // Create streams for reading and writing lines of text
            // from and to this socket.
            sin = new DataInputStream(s.getInputStream());
            sout = new PrintStream(s.getOutputStream());

            // Tell the user that we've connected
            System.out.println("Connected to " + s.getInetAddress()
                       + ":"+ s.getPort());
            }
			catch (IOException e) { System.err.println(e); }
	}

	public String get() {
		String line=null;  
		// Read a line from the server.
		try {
			line = sin.readLine();
			//System.out.println("from server " + line);
			// Check if connection is closed (i.e. for EOF)
			if (line == null) { 
				System.out.println("Connection closed by server.");
			}
        }
        catch (IOException e) { System.err.println(e); }
	return line;
	}
	
	public void send(String line) {

		// Send a line to the server.
		//try {
			sout.println(line);
        //}
        //catch (IOException e) { System.err.println(e); }
	}        
        // Always be sure to close the socket
    public void close() {
            try { if (s != null) s.close(); } catch (IOException e2) { ; }
	}
}



