#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define flt float

void stop_on_error(const char *msg, int error_num) {
   printf(" %s\n",msg);
   printf(" Stopping Program!\n");
   exit(error_num);
}

int f_read_hdr(FILE *infile,int expected_bytes) {
  int number_in_rec;
  return 0;
  if ((fread(&number_in_rec,sizeof(int),1,infile)) != 1) \
    stop_on_error(" Error reading input file!",2);
  if (number_in_rec < expected_bytes) \
    stop_on_error(" Less than expected amount of data in record in input file!",3);
}

main() {
 int ni,nj,nk,ntot,i,j,ii;
 flt *func,*xy,x,y,dx,dy,xrange=1.,yrange=1.;
 flt fmin,fmax;

 char answer[256],cmd[256];

 char infile_name[256];
 FILE *infile;

 char plotfile_name[256]="gnuplot_plotfile";
 FILE *plotfile;

 char cmdfile_name[256]="gnuplot_commandfile";
 FILE *cmdfile;

 printf(" This program will convert a Plot3D\n");
 printf(" file into a pair of files suitable for use with GNUplot\n");
 printf(" \n");
#ifdef NOT
 printf(" It will also optionally use GNUplot to plot the files.\n");
#endif

 /* Open the output files for write access */
 if ( (plotfile=fopen(plotfile_name,"w+")) == NULL) \
   stop_on_error("Error trying to open the output plotting file!",10);
 if ( (cmdfile=fopen(cmdfile_name,"w+")) == NULL) \
   stop_on_error("Error trying to open the output command file!",11);

 printf("\n Please Enter the Plot3D format input file name: ");
 scanf("%s",infile_name);

 if ( (infile=fopen(infile_name,"r")) == NULL) \
   stop_on_error("Error trying to open the input file!",1);

 /* Read the header for the input file */
/* f_read_hdr(infile,3*sizeof(int)); 
 fread(&ni,sizeof(int),1,infile);
 fread(&ni,sizeof(int),1,infile);
 fread(&nj,sizeof(int),1,infile);
 fread(&nk,sizeof(int),1,infile);
 f_read_hdr(infile,3*sizeof(int)); 
*/
 fscanf(infile,"%d",&ni);
 fscanf(infile,"%d",&nj);
 nk=1;
/*fscanf(infile,"%d",&nk);*/
 
 printf("\n Dimensions of input file: NI:%6.0d NJ:%6.0d NK:%6.0d\n",ni,nj,nk);

 ntot = ni*nj*nk;
 func  = (flt *)malloc(sizeof(flt)*ntot);
 xy    = (flt *)malloc(sizeof(flt)*ntot*2);

 /* Read the function from the input file */
/*
 f_read_hdr(infile,ntot*sizeof(flt));
 fread(func,sizeof(flt),ntot,infile);
 f_read_hdr(infile,ntot*sizeof(flt));
*/
 ii = 0;
 fmin=(1e10);
 fmax=(-1e10);
 for (j=0; j<nj; j++) {
   for (i=0; i<ni; i++) {
     fscanf(infile,"%e",&func[ii]);
     if(func[ii] < fmin)fmin=func[ii];
     if(func[ii] > fmax)fmax=func[ii];
     ii++;
   }
 }
 printf("%g   %g\n",fmin,fmax);
 /* Calculate an X and Y array */
 dx = xrange/((flt)(ni-1));
 dy = yrange/((flt)(nj-1));
 for (j=0; j<nj; j++) {
   y = 0. + dy*(flt)(j);
   for (i=0; i<ni; i++) {
     x = 0. + dx*(flt)(i);
     xy[i+ni*j      ] = x;
     xy[i+ni*j+ntot] = y;
   }
 }

 /* Write out the GNUplot command file */
 fprintf(cmdfile,"%s\n","#This is a GNUPLOT command file.");
 fprintf(cmdfile,"%s\n",
 "#For details on these commands, see http://www.cs.cf.ac.uk/Latex/Gnuplot/");
 fprintf(cmdfile,"set xrange [%6.2f:%6.2f]\n",0.,xrange);
 fprintf(cmdfile,"set yrange [%6.2f:%6.2f]\n",0.,yrange);
 fprintf(cmdfile,"%s\n","set parametric");
 fprintf(cmdfile,"%s\n","set cntrparam levels 25");
 fprintf(cmdfile,"%s\n","set contour");
 fprintf(cmdfile,"%s\n","set view 0,0,1");
 fprintf(cmdfile,"%s\n","set nosurface");
 fprintf(cmdfile,"%s\n","set output \"plotfile.ps\"");
 fprintf(cmdfile,"%s\n","set terminal postscript landscape color solid");
 fprintf(cmdfile,"%s%s%s\n","splot '",plotfile_name,"' using 1:2:3 with lines");
 fprintf(cmdfile,"%s\n","replot");

 /* Write out the GNUplot plotting file */
 ii = 0;
 for (j=0; j<nj; j++) {
   for (i=0; i<ni; i++) {
     fprintf(plotfile,"%12.4f %12.4f %12.4f\n",xy[ii],xy[ii+ntot],func[ii]);
     ii++;
   }
   fprintf(plotfile,"\n");
 }

 printf("\n You should now be able to execute the command:\n");
 printf("\t\t\"gnuplot %s\"\n",cmdfile_name);
 printf(" to get a 2D XY contour plot and postscript printable output.\n");
 printf(" \n\n Normal Termination.\n");
#ifdef NOT
 /* Optionally, plot the data */
 printf("\n Would you like to plot the data? (yes or no): ");
 scanf("%s",answer);

 if (strstr(answer,"y")) {
   cmd[0]='\0';
   strcat(cmd,"/usr/bin/gnuplot ");
   strcat(cmd,cmdfile_name);
   strcat(cmd,"\n");
   printf("command to be executed: %s\n",cmd);
   system(cmd);
 }
#endif

}

