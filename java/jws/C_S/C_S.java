import java.io.*;

public class C_S {

    public C_S () {
    }

    public static void main(String args[]) {
    	Client my_Client;
	Server my_Server;
	String my_args[]=new String[2];
	my_Server=new Server(0);
	my_Server.start();	
	my_args[0]="surt.gso.saic.com";
	my_args[1]="/usr/bin/ls";
//	my_Client=new Client(my_args);
    }
}

