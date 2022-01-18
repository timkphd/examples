import java.awt.*;
import java.util.*;

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
			
