#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
main() {
//# 0 - stdin
//# 1 - stdout
//# 2 - stderr
int a,b,k;

//# 0 - stdin
// save a pointer to the real stdin
int saveStdin=dup(0);

// open a file that will become stdin
int fd = open("vals",O_RDONLY) ; // … or a call to pipe() or socket()
if (0 > fd)  return 1;

//   int dup2(int oldfd, int newfd);
//   dup2() makes newfd be the copy of oldfd, closing newfd first if necessary

int r1 = dup2(fd, 0) ;
int r2 = close(fd) ;

// now read from stdin first from the file 
// then restore the real stdin and read from there
 for (k=0;k<5;k++) {
   scanf("%d %d",&a,&b);
   printf("read # %d   -> %d %d\n",k+1,a,b);
   if ( k == 2){
       dup2(saveStdin, 0);
       close(saveStdin);
   }
 }

}

