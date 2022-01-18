
import java.io.*;
public class test_io {

    public test_io () {
    }

    public static void main(String args[]) {
	String a_Line;
	DataInputStream in= new DataInputStream(System.in);
	try {
	    System.out.println("enter a Line: ");
	    a_Line=in.readLine();
	    System.out.println(a_Line);
	    }
	catch (IOException ioe) { System.err.println(ioe); }
	a_Line= null;
	System.out.println(a_Line == null);
    }
}

