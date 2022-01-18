// This example is from the book _Java in a Nutshell_ by David Flanagan.
// Written by David Flanagan.  Copyright (c) 1996 O'Reilly & Associates.
// You may study, use, modify, and distribute this example for any purpose.
// This example is provided WITHOUT WARRANTY either expressed or implied.

import java.awt.*;

public class ReallyQuitDialog extends YesNoDialog {
    TextComponent status;
    Frame Parent;
    // Create the kind of YesNoDialog we want
    // And store away a piece of information we need later.
    public ReallyQuitDialog(Frame parent, String header, TextComponent status) { 
        super(parent, header, status.getText(), "Ok", null, "Cancel",true);
        this.status = status;
	Parent=parent;
    }
    // Define these methods to handle the user's answer
    public void yes() { 
        if (status != null) {
	    status.setText("Ok");
	    //System.out.println(the_field.getText());
	    ((Client_GUI)Parent).dir= new String(the_field.getText());
	    }
    }
    public void no() { 
        if (status != null) status.setText("no"); 
    }
    public void cancel() { 
        if (status != null) status.setText("cancel"); 
    }
}