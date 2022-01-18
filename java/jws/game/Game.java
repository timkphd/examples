/*
	Trivial applet that displays a string - 4/96 PNL
*/

import java.awt.*;
import java.applet.Applet;
import java.util.*;


public class Game extends Applet
{
	Button  shapeChoice1;
	static boolean  Solution[][]=new boolean[15][14];
	static int step,klast;
	short one=0;
	Display c,d;
	public void paint( Graphics g ) {
	if(c != null){
		g.drawString( "Found Solution", 30, 150 );
		c.draw(g);
	}
	else
	d.draw(g);
	}
	
   public boolean mouseUp(Event e, int x, int y) {
   	int i,dis,dismin,j;
   	if(c != null){
   		step++;
   		if(step >= 14)step=klast;
   		for(i=0;i<=14;i++){
   			c.Filled[i]=Solution[i][step];
   		}
			repaint();
		}
		else{
		     i=0;
		     dis=(d.xloc[i]-x)*(d.xloc[i]-x)+(d.yloc[i]-y)*(d.yloc[i]-y);
		     j=0;
		     dismin=dis;
   		  for(i=1;i<=14;i++){
   			dis=(d.xloc[i]-x)*(d.xloc[i]-x)+(d.yloc[i]-y)*(d.yloc[i]-y);
   			//System.out.println(x+" " + d.xloc[i]+ " "+y+" " + d.yloc[i]+" " + dis);
   			if(dis < dismin){
   				j=i;
   				dismin=dis;
   			}
   			}
   		   for(i=0;i<=14;i++){
   			    d.Filled[i]=true;
   		   }
   		   d.Filled[j]=false;
   			repaint();
   		
		
		}
		return true;
   }
   
	public void init() {
   
      shapeChoice1 = new Button("go");
      shapeChoice1.setForeground(Color.black);
      shapeChoice1.setBackground(Color.lightGray);
      add(shapeChoice1);
      d = new Display();
		d.initialize();
      
   }
   
	public boolean action(Event event,Object arg){
	int i;
	if(event.target==shapeChoice1){
	   		   for(i=0;i<=14;i++){
   			    if(!d.Filled[i])one=(short)i;
   			    d.Filled[i]=true;
   		  		 }

					shapeChoice1.show(false);
					removeAll();
					repaint(0,0,200,200);

					Board Aboard = new Board(one);
					Aboard.Set_repeat();
      			try {
      				
      				Aboard.Moves();
      			}
      			catch (Found_Solution f) {
         			
         			System.out.println("repeats " + Aboard.repeats + " new boards " + Aboard.news);
         			c = new Display();
						c.initialize();
						step=klast-1;      
      			}


	return true;
	}
	else return super.action(event,arg);

	}
}
