import java.io.*;
import java.net.*;
import java.awt.*;
import java.util.*;

public class Client_GUI extends Frame {

    MenuBar menubar;                	// the menubar
    Menu file;   		             	// menu panes
    Menu messages;   		             	// menu panes
    Menu directories;   		             	// menu panes
    Button send, clear,quit;    		// buttons
    List list;                      	// A list of choices
    CheckboxGroup checkbox_group;   	// A group of button choices
    Checkbox[] checkboxes;          	// the buttons to choose from
    TextField[] textfield;            	// One line of text input
    TextArea  textarea;             	// A text window    
    Panel panel1;    			// Sub-containers for all this stuff.
    Panel buttonpanel;
    String dir = (String)"/home/tuxedo/misc/test/";
    ReallyQuitDialog d;
    protected String[] services;

// The layout manager for each of the containers.
    GridBagLayout gridbag = new GridBagLayout();
    
    public Client_GUI(	String title,
			String in_dir,
			String in_machine,
			String in_services,
			String in_messages) {
        super(title);
	if(in_dir != null){
	    dir = new String(in_dir);
	}
	if(in_services != null){
	    StringTokenizer t = new StringTokenizer(in_services," ");
	    int n=t.countTokens();
	    services= new String[n];
	    for(int i=0;i<n;i++){
		services[i]=t.nextToken();
	    }
	}
	else {
	    services= new String[1];
	    services[0]="schedule";
	}
// Create the menubar.  Tell the frame about it.
        menubar = new MenuBar();
        this.setMenuBar(menubar);
// Create the file menu.  Add items to it.  Add to menubar.
        file = new Menu("File");
        file.add(new MenuItem("Quit"));
        menubar.add(file);
	messages = new Menu("Messages");
	if(in_messages != null){
	    StringTokenizer t = new StringTokenizer(in_messages," ");
	    int n=t.countTokens();
	    for(int i=0;i<n;i++){
		messages.add(new MenuItem(t.nextToken()));
	    }
	}
	else {
	    messages.add(new MenuItem("DUMP"));
	    messages.add(new MenuItem("HALT service_name"));
	    messages.add(new MenuItem("HALTALL"));
	    messages.add(new MenuItem("INIT"));
	    messages.add(new MenuItem("KICK"));
	    messages.add(new MenuItem("SHOW"));
	    messages.add(new MenuItem("STALL service_name"));
	    messages.add(new MenuItem("START \"server=LOG1 schedule-type=cron time=5 message=5d\""));
	    messages.add(new MenuItem("STATE=1"));
	    messages.add(new MenuItem("UNSTALL service_name"));
	    messages.add(new MenuItem("VERBOSE"));
	    messages.add(new MenuItem("WAIT"));
	}
        menubar.add(messages);
	
//	System.out.println(System.getProperty("java.version"));
//	System.out.println(System.getProperty("java.vendor"));
//	System.out.println(System.getProperty("java.vendor.url"));
//	System.out.println(System.getProperty("java.class.version"));

// dialog box is broken in Netscape java version 1.02
// check for this and do not display if true
	boolean dialog_works;
	dialog_works=true;
	String str1= "Netscape Communications Corporation";
	if(str1.compareTo(System.getProperty("java.vendor")) == 0){
	    str1= "1.02";
	    if(str1.compareTo(System.getProperty("java.version")) == 0) {
		dialog_works=false;
	    }
	}		
	dialog_works=true;
	if(dialog_works) {
	    directories = new Menu("Directories");
	    directories.add(new MenuItem("Tuxedo Directory"));
	    menubar.add(directories);
	}
// Create pushbuttons
        send = new Button("Send");
        clear = new Button("Clear");
        quit = new Button("Close");
// Create checkboxes, and group them.
        checkbox_group = new CheckboxGroup();
        checkboxes = new Checkbox[2];
        checkboxes[0] = new Checkbox("Synchronous", checkbox_group, false);
        checkboxes[1] = new Checkbox("Asynchronous", checkbox_group, true);
// Create a list of server choices.
        list = new List(2, false);
	for(int i=0; i< services.length;i++){
	    list.addItem(services[i]);
	}
// Create a one-line text fields, and multi-line text area.
        textfield = new TextField[3];
        textfield[0] = new TextField(15);
	textfield[0].setText(services[0]);
        textfield[1] = new TextField(60);
        textfield[2] = new TextField(15);
	if(in_machine != null) {
		textfield[2].setText(in_machine);
	}
	else {
		textfield[2].setText("norns.gso.saic.com");
	}
        textarea = new TextArea(6, 40);
        textarea.setEditable(false);
// Create a Panel to contain all the components along the
// left hand side of the window.  Use a GridBagLayout for it.
        panel1 = new Panel();
        panel1.setLayout(gridbag);        
// Use several versions of the constrain() convenience method
// to add components to the panel and to specify their 
// GridBagConstraints values.
        constrain(panel1, new Label("Service Name:"),            0, 0, 1, 1);
        constrain(panel1, textfield[0],                          0, 1, 1, 1);
        constrain(panel1, new Label("Message to Service:"),      0, 2, 1, 1);
        constrain(panel1, textfield[1],                          0, 3, 2, 1);
        constrain(panel1, new Label("Type of call:"),            0, 4, 1, 1);
        constrain(panel1, checkboxes[0],                         0, 5, 1, 1);
        constrain(panel1, checkboxes[1],                         0, 6, 1, 1);
        constrain(panel1, new Label("Favorite Service:"),        0, 8, 1, 1, 10, 0, 0, 0);
//        constrain(panel1, list,                                  0, 9, 1, 3, 
//                  GridBagConstraints.VERTICAL,
//                  GridBagConstraints.NORTHWEST, 0.0, 1.0, 0, 0, 0, 0);
        constrain(panel1, list,                                  0, 9, 1, 3); 
                  
		          
// Create a panel for the items along the right side.
// Use a GridBagLayout, and arrange items with constrain(), as above.
        constrain(panel1, new Label("  Tuxedo Machine:"),     1, 0, 1, 1);
         constrain(panel1, textfield[2],			 1, 1, 1, 1,
                  GridBagConstraints.HORIZONTAL,
                  GridBagConstraints.NORTHEAST, 1.0, 0.0, 0, 10, 0, 0);
        constrain(panel1, new Label("  Message from server:"),     1, 6, 1, 1);
        constrain(panel1, textarea,                                1, 7, 1, 3,
                  GridBagConstraints.VERTICAL,
                  GridBagConstraints.NORTHWEST, 1.0, 1.0, 5, 5, 0, 0);
        
// Do the same for the buttons along the bottom.
        buttonpanel = new Panel();
        buttonpanel.setLayout(gridbag);
        constrain(buttonpanel, send,       0, 0, 1, 1, GridBagConstraints.NONE,
              GridBagConstraints.CENTER,                   0.3, 0.0, 0, 0, 0, 0);
        constrain(buttonpanel, clear,      1, 0, 1, 1, GridBagConstraints.NONE,
              GridBagConstraints.CENTER,                   0.3, 0.0, 0, 0, 0, 0);
        constrain(buttonpanel, quit,       2, 0, 1, 1, GridBagConstraints.NONE,
              GridBagConstraints.CENTER,                   0.3, 0.0, 0, 0, 0, 0);       
// Finally, use a GridBagLayout to arrange the panels themselves
        this.setLayout(gridbag);
// And add the panels to the toplevel window
        constrain(this, panel1, 0, 0, 1, 1, GridBagConstraints.VERTICAL, 
              GridBagConstraints.NORTHWEST, 0.0, 1.0, 10, 10, 5, 5);
        constrain(this, buttonpanel, 0, 1, 2, 1, GridBagConstraints.HORIZONTAL,
              GridBagConstraints.CENTER, 1.0, 0.0, 5, 0, 0, 0);
    }
    
    public void constrain(Container container, Component component, 
                  int grid_x, int grid_y, int grid_width, int grid_height,
                  int fill, int anchor, double weight_x, double weight_y,
                  int top, int left, int bottom, int right)
    {
        GridBagConstraints c = new GridBagConstraints();
        c.gridx = grid_x; c.gridy = grid_y;
        c.gridwidth = grid_width; c.gridheight = grid_height;
        c.fill = fill; c.anchor = anchor;
        c.weightx = weight_x; c.weighty = weight_y;
        if (top+bottom+left+right > 0)
            c.insets = new Insets(top, left, bottom, right);
        
        ((GridBagLayout)container.getLayout()).setConstraints(component, c);
        container.add(component);
    }
    
    public void constrain(Container container, Component component, 
                  int grid_x, int grid_y, int grid_width, int grid_height) {
        constrain(container, component, grid_x, grid_y, 
              grid_width, grid_height, GridBagConstraints.NONE, 
              GridBagConstraints.NORTHWEST, 0.0, 0.0, 0, 0, 0, 0);
    }
    
    public void constrain(Container container, Component component, 
                  int grid_x, int grid_y, int grid_width, int grid_height,
                  int top, int left, int bottom, int right) {
        constrain(container, component, grid_x, grid_y, 
              grid_width, grid_height, GridBagConstraints.NONE, 
              GridBagConstraints.NORTHWEST, 
              0.0, 0.0, top, left, bottom, right);
    }
    
    public boolean action(Event e, Object o){
    	if(e.target instanceof Checkbox){
    	}
    	if(e.target instanceof List) {
    			textfield[0].setText((String)e.arg);
			int i,j;
			i=((List)(e.target)).countItems();
			for(j=0;j<i;j++)((List)(e.target)).deselect(j);
    	}
		if(e.target instanceof MenuItem) {
		    if(((MenuItem)(e.target)).getLabel() == "Quit"){
			this.dispose();
			return true;
			}
		    if(((MenuItem)(e.target)).getLabel() == "Tuxedo Directory"){
			if(d != null) {
			   /* if(d.status.getText()=="Ok")
				dir=new String(d.the_field.getText());*/
			    d.hide();
			    d.dispose();
			}
			TextArea textarea =new TextArea(dir);
			Frame aframe=new Frame();
			d = new ReallyQuitDialog((Frame)this,"Tuxedo Directory?",(TextComponent)textarea);
			//ReallyQuitDialog d= new ReallyQuitDialog((Frame)this,"Tuxedo Directory?",(TextComponent)textarea);
			//panel1.add(d);
			d.show();
			//while( d.status.getText()!="Ok" && d.status.getText()!="cancel"){}
		    
			//d.dispose();
			return true;
			}
		    else {
			textfield[1].setText(((MenuItem)(e.target)).getLabel());
			return true;
			}
			
		}    	
    	if(e.target instanceof Button) { 
    		if(send == e.target){
			    /*if(d.status.getText()=="Ok")
			    dir=new String(d.the_field.getText());
			    */
			    String readthis = (String) o;
			//System.out.println(checkbox_group.getCurrent().getLabel());
			//System.out.println(checkbox_group.getCurrent().getLabel().compareTo("Synchronous"));
				if(checkbox_group.getCurrent().getLabel().compareTo("Synchronous")==0){
					readthis = (String)(dir + "/Send -s "
							+ textfield[0].getText() +	//server name
						" " + textfield[1].getText());  //args for server
    			}
    			else
    				readthis = (String)(dir + "/Send -a "
    						+ textfield[0].getText() +	//server name
						" " + textfield[1].getText());	//args for server
			/*
			try {
			    Runtime rt = Runtime.getRuntime();
			    Process prcs =rt.exec("/home/tuxedo/test/"+readthis);
			    DataInputStream d = new DataInputStream(prcs.getInputStream());
			    String aline;
			    while((aline =d.readLine()) != null){
				textarea.appendText("\n" + aline);
			    }
			}
			catch (IOException f) { ; }
			*/
			    Client my_Client;
			    String my_args[]=new String[2];
			    my_args[0]=textfield[2].getText();
			    my_args[1]=readthis;
			    System.out.println(readthis);
			    my_Client=new Client(my_args,textarea);

			textarea.appendText("\n");
       		}
    		if(clear == e.target){
    			textarea.setText("");
    			textfield[0].setText("");
    			textfield[1].setText("");
    		}
    		if(quit == e.target){
				this.dispose();
				return true;
    		}
    	}
    		return true;
    }
/******   
 public static void main(String[] args) {
	String my_args[]=new String[1];
        Frame f = new Client_GUI("Basic Client GUI");
// We should call f.pack() here.  But its buggy.
        f.resize(525, 375);
        f.show();
    }
******/
}
