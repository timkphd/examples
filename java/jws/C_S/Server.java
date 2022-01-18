import java.io.*;
import java.net.*;
public class Server extends Thread{
	public final static int DEFAULT_PORT=3456; 
	protected int port;
	protected ServerSocket listen_socket;
	public static void fail(Exception e, String msg){
		System.err.println(msg + ":" + e);
		System.exit(1);
	}
	
	public Server(int port){
		if(port == 0)port=DEFAULT_PORT;
		this.port=port;
		try {listen_socket = new ServerSocket(port);}
		catch (IOException e) {fail(e, "Exception creating server socket");}
		System.out.println("Server.listening on port  "+ port);
	}
	
	public void run() {
		try{
			while(true) {
				Socket client_socket = listen_socket.accept();
				Connection c = new Connection(client_socket);
			}
		}
		catch (IOException e) {fail(e, "Exception while listening for connections");}
	}
	
	public static void main(String[] args){
		int port = 0;
		if(args.length == 1){
			try{port = Integer.parseInt(args[0]);}
			catch (NumberFormatException e){port = 0;}
		}
		new Server(port);
	}
}


