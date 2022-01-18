import java.applet.Applet;
import java.io.*;
import java.net.*; 
import java.awt.*;
import java.util.Random;
import java.security.SecureRandom;
public class www_client extends Applet {
    Client_GUI F;
    /**
     * Initializes the applet.  You never need to call this directly; it is
     * called automatically by the system once the applet is created.
     */
    public void init() {
    }

    /**
     * Called to start the applet.  You never need to call this directly; it
     * is called when the applet's document is visited.
     */
    public void start() {
//	System.out.println(System.getProperty("java.version"));
//	System.out.println(System.getProperty("java.vendor"));
//	System.out.println(System.getProperty("java.vendor.url"));
/*
1.02
Netscape Communications Corporation
http://home.netscape.com
*/
/**********
    SecureRandom s1,s2;
    byte[] Bike;
    int i,j;
    String boink="Tuxedo";
    j=boink.length();
    Bike=new byte[j];
    boink.getBytes(0,j,Bike,0);
    s1 = new SecureRandom(Bike);
    s2 = new SecureRandom(Bike);
    System.out.println(s1.nextInt());
    System.out.println(s2.nextInt());
**********/
Frame f = new Client_GUI("Basic Client GUI",
	    getParameter("tux_dir"),
	    getParameter("tux_machine"),
	    getParameter("services"),
	    getParameter("messages"));
	    
// We should call f.pack() here.  But its buggy.
        f.resize(525, 375);
        f.show();
 }

    /**
     * Called to stop the applet.  This is called when the applet's document is
     * no longer on the screen.  It is guaranteed to be called before destroy()
     * is called.  You never need to call this method directly
     */
    public void stop() {
    }

    /**
     * Cleans up whatever resources are being held.  If the applet is active
     * it is stopped.
     */
    public void destroy() {
    }
}

