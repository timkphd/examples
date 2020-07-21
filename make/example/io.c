#include "io.h"
void io(double t1_start, double t1_end, double e1,
        double t2_start, double t2_end, double e2,
        double t3_start, double t3_end, double e3,
        double t4_start, double t4_end, double e4)
{
 printf("section 1 start time= %10.5g   end time= %10.5g  error= %g\n",t1_start,t1_end,e1);
 printf("section 2 start time= %10.5g   end time= %10.5g  error= %g\n",t2_start,t2_end,e2);
 printf("section 3 start time= %10.5g   end time= %10.5g  error= %g\n",t3_start,t3_end,e3);
 printf("section 4 start time= %10.5g   end time= %10.5g  error= %g\n",t4_start,t4_end,e4);
}
