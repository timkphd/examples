
public class client {

    /**
     * Constructor.
     */
    public client () {
    }

    public static void main(String args[]) {
    
	A_Client my_client;
	String my_args[]=new String[1];
	System.out.println("Hello World!");
	my_args[0]="fimafeng.gso.saic.com";
	my_client=new A_Client(my_args);
	
    }
}

