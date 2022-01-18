// This example is from the book _Java in a Nutshell_ by David Flanagan.
// Written by David Flanagan.  Copyright (c) 1996 O'Reilly & Associates.
// You may study, use, modify, and distribute this example for any purpose.
// This example is provided WITHOUT WARRANTY either expressed or implied.

import java.awt.*;
class Found_Solution extends Exception {
}


public class TrivialApplication extends Frame {
    static B_Client my_Client;

    MenuBar menubar;                // the menubar
    Menu file, help;                // menu panes
    Button okay, clear;            // buttons
    List list;                      // A list of choices
    Choice choice;                  // A menu of choices
    CheckboxGroup checkbox_group;   // A group of button choices
    Checkbox[] checkboxes;          // the buttons to choose from
    TextField textfield;            // One line of text input
    TextArea  textarea;             // A text window
//    ScrollableScribble scribble;    // An area to draw in.
    FileDialog file_dialog;
    
    Panel panel1, panel2 ;    // Sub-containers for all this stuff.
    Panel buttonpanel; 

    // The layout manager for each of the containers.
    GridBagLayout gridbag = new GridBagLayout();
    
    public TrivialApplication(String title) {
        super(title);
        
        // Create the menubar.  Tell the frame about it.
        menubar = new MenuBar();
        this.setMenuBar(menubar);
        // Create the file menu.  Add two items to it.  Add to menubar.
        file = new Menu("File");
        file.add(new MenuItem("Open"));
        file.add(new MenuItem("Quit"));
        menubar.add(file);
        // Create Help menu; add an item; add to menubar
        help = new Menu("Help");
        help.add(new MenuItem("About"));
        menubar.add(help);
        // Display the help menu in a special reserved place.
        menubar.setHelpMenu(help);
        
        // Create pushbuttons
        okay = new Button("Okay");
        clear = new Button("Clear");
        
        // Create a menu of choices
        choice = new Choice();
        choice.addItem("red");
        choice.addItem("green");
        choice.addItem("blue");
        
        // Create checkboxes, and group them.
        checkbox_group = new CheckboxGroup();
        checkboxes = new Checkbox[3];
        checkboxes[0] = new Checkbox("Status", checkbox_group, false);
        checkboxes[1] = new Checkbox("Launch", checkbox_group, true);
        checkboxes[2] = new Checkbox("Kill", checkbox_group, false);
        
        // Create a list of choices.
        list = new List(4, true);
        list.addItem("w_07"); list.addItem("w_29");
        list.addItem("w_11"); list.addItem("w_31");
        list.addItem("w_13"); list.addItem("w_37");
        list.addItem("w_17"); list.addItem("w_41");
        list.addItem("w_19");
        list.addItem("w_23");
        
        // Create a one-line text field, and multi-line text area.
        textfield = new TextField(15);
        textarea = new TextArea(6, 40);
        textarea.setEditable(false);
        
        // Create a scrolling canvas to scribble in. 
//        scribble = new ScrollableScribble();
        
        // Create a file selection dialog box
        file_dialog = new FileDialog(this, "Open File", FileDialog.LOAD);
        
        // Create a Panel to contain all the components along the
        // left hand side of the window.  Use a GridBagLayout for it.
        panel1 = new Panel();
        panel1.setLayout(gridbag);
        
        // Use several versions of the constrain() convenience method
        // to add components to the panel and to specify their 
        // GridBagConstraints values.
        constrain(panel1, new Label("Send to server:"), 0, 0, 1, 1);
        constrain(panel1, textfield, 0, 1, 1, 1);
        constrain(panel1, new Label("Desired Action:")     , 0, 2, 1, 1,10, 0, 0, 0);
        constrain(panel1, choice, 0, 3, 1, 1);
        constrain(panel1, new Label("Favorite color:")     , 0, 4, 1, 1,10, 0, 0, 0);
        constrain(panel1, checkboxes[0], 0, 5, 1, 1);
        constrain(panel1, checkboxes[1], 0, 6, 1, 1);
        constrain(panel1, checkboxes[2], 0, 7, 1, 1);
        constrain(panel1, new Label("Normal Applications:"), 0, 8, 1, 1,10, 0, 0, 0);
        constrain(panel1, list, 0, 9, 1, 3, GridBagConstraints.VERTICAL,
              GridBagConstraints.NORTHWEST, 0.0, 1.0, 0, 0, 0, 0);
        
        // Create a panel for the items along the right side.
        // Use a GridBagLayout, and arrange items with constrain(), as above.
        panel2 = new Panel();
        panel2.setLayout(gridbag);
        
        constrain(panel2, new Label("Messages from server"), 0, 0, 1, 1);
        constrain(panel2, textarea, 0, 1, 1, 3, GridBagConstraints.HORIZONTAL,
              GridBagConstraints.NORTH, 1.0, 0.0, 0, 0, 0, 0);
        constrain(panel2, new Label("Diagram"), 0, 4, 1, 1, 10, 0, 0, 0);
 //       constrain(panel2, scribble, 0, 5, 1, 5, GridBagConstraints.BOTH,GridBagConstraints.CENTER, 1.0, 1.0, 0, 0, 0, 0);
        
        // Do the same for the buttons along the bottom.
        buttonpanel = new Panel();
        buttonpanel.setLayout(gridbag);
        constrain(buttonpanel, okay, 0, 0, 1, 1, GridBagConstraints.NONE,
              GridBagConstraints.CENTER, 0.3, 0.0, 0, 0, 0, 0);
        constrain(buttonpanel, clear, 1, 0, 1, 1, GridBagConstraints.NONE,
              GridBagConstraints.CENTER, 0.3, 0.0, 0, 0, 0, 0);
        
        // Finally, use a GridBagLayout to arrange the panels themselves
        this.setLayout(gridbag);
        // And add the panels to the toplevel window
        constrain(this, panel1, 0, 0, 1, 1, GridBagConstraints.VERTICAL, 
              GridBagConstraints.NORTHWEST, 0.0, 1.0, 10, 10, 5, 5);
        constrain(this, panel2, 1, 0, 1, 1, GridBagConstraints.BOTH,
              GridBagConstraints.CENTER, 1.0, 1.0, 10, 10, 5, 10);
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
    	if(e.target instanceof TextField) {
    		String readthis = (String) o;
    		//System.out.println(readthis);
    		my_Client.send(readthis);
    		if(textfield == e.target)textfield.setText("");
    		String back=my_Client.get();
        	textarea.setText(textarea.getText()+"from server: "+back+"\n");
    		//System.out.println(back);
    	}
    	if(e.target instanceof Button) {
    		if(okay == e.target){
    			System.out.println("Closing client");
    			my_Client.close();
    			dispose();
    		}
    		if(clear == e.target){
    			textarea.setText("");
    		}
    	}
    	if(e.target instanceof Choice) {
    		if(choice == e.target){
    		System.out.println("did choice");
    		int i;
    		i=choice.getSelectedIndex();
		    if(i == 0){
    			Color acolar = new Color(255,0,0);
			choice.setBackground(acolar);
		    }
     		    if(i == 1){
    			Color acolar = new Color(0,255,0);
			choice.setBackground(acolar);
		    }
		    if(i == 2){
    			Color acolar = new Color(0,0,255);
			choice.setBackground(acolar);
		    }
		   
		    System.out.println(choice.getBackground());
     		}
    	}

    		return true;
    }
    public static void main(String[] args) {
		String my_args[]=new String[1];
        Frame f = new TrivialApplication("AWT Demo");
		//System.out.println("Hello World!");
		//my_args[0]="fimafeng.gso.saic.com";
		//my_Client = new B_Client(my_args);
        // We should call f.pack() here.  But its buggy.
        f.resize(450, 475);
        f.show();
        System.out.println("Good by World!");
        
    }
}
