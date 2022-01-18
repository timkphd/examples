import java.applet.Applet;
import java.io.*;
import java.net.*;


public class untitled1 extends Applet {

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
	    System.out.println("Starting");
	    Runtime rt = Runtime.getRuntime();
	    try {
	    Process prcs =rt.exec("/home/od/tkaiser/bin/running xterm");
	    DataInputStream d = new DataInputStream(prcs.getInputStream());
	    String aline;
	    while((aline =d.readLine()) != null)
		System.out.println(aline);
	    }
            catch (IOException e) { ; }

    
    
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

