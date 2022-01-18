/*
	Trivial applet that displays a string - 4/96 PNL
*/

import java.awt.*;
import java.applet.Applet;
import java.util.*;

class Found_Solution extends Exception {
}

public class TrivialApplet extends Applet
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

class Board{
	boolean Filled[]=new boolean[15];
	boolean hasmove=false;
	static Hashtable Tried;
	static int repeats,news;
	static int z1[] = new int[15];
	static int z2[] = new int[15];
	static int z3[] = new int[15];

	Board parent;
	
	public Board(Board myparent){
		short i;
		for (i=0;i<=14;i++){
				Filled[i]=myparent.Filled[i];
		}
		hasmove=false;
		parent=myparent;		
	}
	
	public Board(short j) {
		short i;
		for (i=0;i<=14;i++){
				Filled[i]=true;
		}
		Filled[j]=false;
	}
	
	public void Moves()throws Found_Solution{
		short i;
		int j;
		j=0;
		for (i=0;i<=14;i++){
			if(!(Filled[i]))j=j+1;
			}
		this.hasmove=false;
		for (i=0;i<=14;i++){
			if(!Filled[i]){
				switch(i){
					case 0:
							if(Filled[ 1]  && Filled[ 3])moveit(i,1,3);
							if(Filled[ 2]  && Filled[ 5])moveit(i,2,5);
							break;
					case 1:       
							if(Filled[ 3]  && Filled[ 6])moveit(i,3,6);
							if(Filled[ 4]  && Filled[ 8])moveit(i,4,8);
							break;
					case 2:
							if(Filled[ 4]  && Filled[ 7])moveit(i,4,7);
							if(Filled[ 5]  && Filled[ 9])moveit(i,5,9);
							break;
					case 3:
							if(Filled[ 1]  && Filled[ 0])moveit(i,1,0);
							if(Filled[ 4]  && Filled[ 5])moveit(i,4,5);
							if(Filled[ 6]  && Filled[10])moveit(i,6,10);
							if(Filled[ 7]  && Filled[12])moveit(i,7,12);
							break;
					case 4:
							if(Filled[ 7]  && Filled[11])moveit(i,7,11);
							if(Filled[ 8]  && Filled[13])moveit(i,8,13);
							break;
					case 5:
							if(Filled[ 2]  && Filled[ 0])moveit(i,2,0);
							if(Filled[ 4]  && Filled[ 3])moveit(i,4,3);
							if(Filled[ 8]  && Filled[12])moveit(i,8,12);
							if(Filled[ 9]  && Filled[14])moveit(i,9,14);
							break;
					case 6:
							if(Filled[ 3]  && Filled[ 1])moveit(i,3,1);
							if(Filled[ 7]  && Filled[ 8])moveit(i,7,8);
							break;
					case 7:
							if(Filled[ 4]  && Filled[ 2])moveit(i,4,2);
							if(Filled[ 8]  && Filled[ 9])moveit(i,8,9);
							break;
					case 8:
							if(Filled[ 4]  && Filled[ 1])moveit(i,4,1);
							if(Filled[ 7]  && Filled[ 6])moveit(i,7,6);
							break;
					case 9:
							if(Filled[ 5]  && Filled[ 2])moveit(i,5,2);
							if(Filled[ 8]  && Filled[ 7])moveit(i,8,7);
							break;
					case 10:
							if(Filled[ 6]  && Filled[ 3])moveit(i,6,3);
							if(Filled[11]  && Filled[12])moveit(i,11,12);
							break;
					case 11:
							if(Filled[ 7]  && Filled[ 4])moveit(i,7,4);
							if(Filled[12]  && Filled[13])moveit(i,12,13);
							break;
					case 12:
							if(Filled[ 7]  && Filled[ 3])moveit(i,7,3);
							if(Filled[ 8]  && Filled[ 5])moveit(i,8,5);
							if(Filled[11]  && Filled[10])moveit(i,11,10);
							if(Filled[13]  && Filled[14])moveit(i,13,14);
							break;
					case 13:
							if(Filled[ 8]  && Filled[ 4])moveit(i,8,4);
							if(Filled[12]  && Filled[11])moveit(i,12,11);
							break;
					case 14:
							if(Filled[ 9]  && Filled[ 5])moveit(i,9,5);
							if(Filled[13]  && Filled[12])moveit(i,13,12);
				}
			}
		}
	}
	
	private void moveit(int o,int j,int m) throws Found_Solution{
		int a,c,k,z,r2,r3;
	
		this.hasmove=true;
		z=0;
		for (a=0;a<=14;a++){
			if(this.Filled[a])z=z+z1[a];
			}
		if( Filled[m])z=z-z1[m];
		if(!Filled[o])z=z+z1[o];
		if( Filled[j])z=z-z1[j];
//		r2=Rot2(z);
//		r3=Rot3(z);
		
		if(Tried.containsKey(new Integer( z)) 
/*
					||
		   Tried.containsKey(new Integer(r2))
		   		||
		   Tried.containsKey(new Integer(r3))
*/		   
		   		){
			repeats++;
			return;
		}
		else {
			news++;
		}
      Board Cboard = new Board(this);
		Cboard.Filled[m]=false;
		Cboard.Filled[o]=true;
		Cboard.Filled[j]=false;		
		Tried.put(new Integer( z), new Integer(1));
//		Tried.put(new Integer(r2), new Integer(1));
//		Tried.put(new Integer(r3), new Integer(1));
		c=0;
		for (a=0;a<=14;a++){
			if(Cboard.Filled[a])c=c+1;
			}
		if(c == 1){
			k=13;
			for (a=0;a<=14;a++){
			TrivialApplet.Solution[a][k]=Cboard.Filled[a];
			}
			while (Cboard.parent != null){
				Cboard=Cboard.parent;
				k--;
				for (a=0;a<=14;a++){
					TrivialApplet.Solution[a][k]=Cboard.Filled[a];
				}
				TrivialApplet.klast=k;
			}
			throw new Found_Solution();
			}
			
		Cboard.Moves();
	}
	
	private void printit(){
		int i;
		for (i=0;i<=14;i++){System.out.print(Filled[i]+" ");}
		System.out.println(" ");
	}

	void Set_repeat(){
		int p,a;
		Tried = new Hashtable(1000);
		p=1;
		for (a=0;a<=14;a++){
			z1[a]=p;
			p=p*2;
			}
		z2[ 0]=z1[14];  z2[ 1]=z1[ 9];  z2[ 2]=z1[13];		
		z2[ 3]=z1[ 5];  z2[ 4]=z1[ 8];  z2[ 5]=z1[12];		
		z2[ 6]=z1[ 2];  z2[ 7]=z1[ 4];  z2[ 8]=z1[ 7];		
		z2[ 9]=z1[11];  z2[10]=z1[ 0];  z2[11]=z1[ 1];		
		z2[12]=z1[ 3];  z2[13]=z1[ 6];  z2[14]=z1[10];
				
		z3[ 0]=z1[10];  z3[ 1]=z1[11];  z3[ 2]=z1[ 6];		
		z3[ 3]=z1[12];  z3[ 4]=z1[ 7];  z3[ 5]=z1[ 3];		
		z3[ 6]=z1[13];  z3[ 7]=z1[ 8];  z3[ 8]=z1[ 4];		
		z3[ 9]=z1[ 1];  z3[10]=z1[14];  z3[11]=z1[ 9];		
		z3[12]=z1[ 5];  z3[13]=z1[ 2];  z3[14]=z1[ 0];		
	}

	int Rot2(int z){
		int p,a,test_val;
		test_val=1;
		p=0;
		for (a=0;a<=14;a++){
			if((z & test_val) != 0)p=p+z2[a];
			test_val=test_val*2;
			}
		return p;
		}
		
	int Rot3(int z){
		int p,a,test_val;
		test_val=1;
		p=0;
		for (a=0;a<=14;a++){
			if((z & test_val) != 0)p=p+z3[a];
			test_val=test_val*2;
			}
		return p;
		}
}


class Display {
	int[] xloc=new int[15];
	int[] yloc=new int[15];
	boolean[] Filled = new boolean[15];
   
   void draw(Graphics g) {
   	int i;
     for(i=0;i<=14;i++){
     	if(!Filled[i]){
     		g.setColor(Color.red);
     		g.drawOval(xloc[i], yloc[i], 6, 6);
     		}
     	else{
     		g.setColor(Color.blue);
     		g.fillOval(xloc[i], yloc[i], 6, 6);
     		}
     }
   }
   
   void initialize() {
      int row,col,j,dy,dx,ystart,xstart;
      ystart=50;
      xstart=75;
      dy=17;
      dx=10;      
      j=0;
      for(row=0;row<=4;row++){
      	for(col=-row;col<=row;col=col+2){
      		yloc[j]=ystart+dx*(row-1);
      		xloc[j]=dx*col+xstart;
      		Filled[j]=true;
      		j++;      		
      	}
      }
   }

}
			
