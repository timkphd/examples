
/*
 * give
 *      give file1 touser
 *      give file1 ... filen touser
 */

/*
Copyright 1996  the Regents of the University of California.

Unless otherwise indicated, this information has been authored by an
employee or employees of the University of California, operator of
the Los Alamos National Laboratory under Contract No. W-7405-ENG-36
with the U.S. Department of Energy.  The U.S. Government has rights
to use, reproduce, and distribute this information.  The public may
copy and use this information without charge, provided that this
Notice and any statement of authorship are reproduced on all copies.
Neither the Government nor the University makes any warranty, express
or implied, or assumes any liability or responsibility for the use of
this information.
*/

/*
gcc give.c -o give 
sudo cp give /usr/local/bin
sudo chown root:root /usr/local/bin/give
sudo chmod 4555  /usr/local/bin/give
*/
#include        <stdio.h>
#include        <stdlib.h>
#include        <string.h>
#include        <sys/types.h>
#include        <sys/stat.h>
#include        <errno.h>
#include        <pwd.h>
/*
#include        <sys/usrv.h>
*/
#include        <sys/param.h> 
#include        <sys/file.h>
#include        <fcntl.h>


#include <unistd.h>

/*
#include        <sys/unistd.h>
#include        <sys/secparm.h>
*/
// long trunc (int fildes);
#define BSIZE 4096
#define OUTBLKSZ  BSIZE*20
int NOBODY;

#define FMODE(A)        (A.st_mode)
#define ISDIR(A)        ((A.st_mode & S_IFMT) == S_IFDIR)
#define ISREG(A)        ((A.st_mode & S_IFMT) == S_IFREG)
#define DIRMODE         (0700 | S_IFDIR)

#define BLKSIZE 16384

#define DOT     "."
#define DELIM   '/'
#define FALSE   0
#define MODEBITS 07777
#define OWN_ONLY 00600
#define READMODE 04
#define TRUE 1
#define TARGETDIR "/projects/give"
#define _UNICOS 9

// char    *malloc();
char    *strrchr();
char    *touser, *tusr;
char    *buf = (char *)NULL;
char    *buf2 = (char *)NULL;
char    *gbuf = (char *)NULL;
extern  int errno;
extern  char *optarg;
extern  int optind, opterr;
struct  passwd  *udb;
struct  stat ns1, ns2;
/* struct  usrv vals; */
//int     getuid(), getgid(), geteuid();
int     duid, dgid, ouid, ogid, oeuid;
int     compart;

char    *name;

void getspace(int fd,long size);
int move(char *src, char *tusr);
char * dname(char *name);




int main(int argc, char*argv[])
//register char *argv[];
{
        register int c, i, r, len, err;
        
udb = getpwnam("nobody");        
NOBODY=udb->pw_gid;
        /*
         * Check for sufficient arguments 
         */
        
        if (argc < 3) {
                fprintf(stderr,"usage:  give file1 ... filen touser\n");
                exit(-1);
        }
        
        
        /*
         * The last argument (the toid) must be a valid username,
         * who really exists.
         */
         
        if (argc > 2) {
            touser = argv[argc-1];
            if ( (udb = getpwnam(touser)) == NULL) {
                fprintf(stderr, "give: unknown user id %s\n", touser);
                        exit(2);
            }
            else   {
               /*
                *  Save uid and form directory path for give 
                */

                ouid = getuid();
                ogid = getgid();
                duid = udb->pw_uid; 
                dgid = NOBODY;
                if ((gbuf = malloc(strlen( TARGETDIR) + strlen(touser) + 4)) == NULL)  {
                    fprintf(stderr,"give: insufficient memory to form %s\n",touser);
                    exit(3);
                }
                sprintf(gbuf,"%s/%s",TARGETDIR,touser);
                tusr = gbuf;
            }
        }       

        /*
         * If stat successful, give directory exits.
         */
        if (stat(TARGETDIR, &ns2) < 0) {
            if (mkdir(TARGETDIR,DIRMODE) < 0) {
                fprintf(stderr,"give: mkdir /usr/tmp/give\n");
                perror("give");
                exit(1);
                }
            if (chmod(TARGETDIR, 0755) < 0) {
                fprintf(stderr,"give: chmod /usr/tmp/give\n");
                perror("give");
                exit(1);
                }
            if (chown(TARGETDIR, 0, NOBODY) < 0) {
                fprintf(stderr,"give: chown /usr/tmp/give\n");
                perror("give");
                exit(1);
                }
        }
        /*
         * If stat fails, then the give/tusr subdirectory doesn't exist,
         * we will create a new subdirectory with right properties.
         */
        if (stat(tusr, &ns2) < 0) {
             if (mkdir(tusr,DIRMODE) < 0) {
                 fprintf(stderr,"give: Cannot make directory: %s\n",tusr);
                 perror("give");
                 exit(1);
             }
#if _UNICOS < 8
             else if (setflvl(tusr,63) != 0) {
                 /*  cannot set seclevel to wildcard  */
                 fprintf(stderr,"give: Cannot make directory: %s\n",tusr);
                 exit(1);
             }
#endif  
             else if (chown(tusr,duid,NOBODY) < 0) {
                 fprintf(stderr,"give: chown failed on directory: %s\n",tusr);
                 perror("give");
                 exit(1);
             }
        }

        
        /*
         * Perform a multiple argument give by
         * multiple invocations of move().
         */
         
        
        r = 0;
        for (i=1; i<argc-1; i++)
                r += strlen(argv[i]);
        if ((buf2 = malloc(r + i + 4)) == NULL) {
                fprintf(stderr,"give: insufficient memory for string\n");
                exit(3);
        }

        r = 0;
        for (i=1; i<argc-1; i++) {
                err = move(argv[i],tusr);
                if (err == 0) {
                        strcat(buf2,argv[i]);
                        strcat(buf2," ");
                }
                else
                        r += err;
        }
        
        /* 
         * Show errors by nonzero exit code.
         */
         
        exit(r?2:0);
}

char     fbuf[BLKSIZE];

int move(char *src, char  *tusr)
{
        register int last, c, i;
        char    *pt, *pc;
        char    *target;
        int from, to, ct, len, err;
        long asize;
        int truncflg;
        long tot;
        
        /* 
         * While src or tusr have trailing 
         * DELIM (/), remove them (unless only "/")
         */

        while (((last = strlen(src)) > 1)
            &&  (src[last-1] == DELIM))
                 src[last-1]=(char)'\0';
        
        while (((last = strlen(tusr)) > 1)
            &&  (tusr[last-1] == DELIM))
                 tusr[last-1]=(char)'\0';
        
        /*
         * Make sure src file exists and giver has access to it.
         */
         
        if ((stat(src,&ns1) < 0) || (access(src,READMODE) < 0 )) {
                fprintf(stderr, "give: cannot access %s\n", src);
                return(1);
        }
        
        /* 
         * Make sure source file is not a directory,
         * we don't move() directories...
         */
        
        if (ISDIR(ns1)) {
                fprintf(stderr, "give: <%s> a directory\n", src);
                return(1);
        }

        /*
         * Make sure giving user is owner of this file.
         */


         if (ouid != ns1.st_uid) {
                fprintf(stderr, "give: must be file owner to give %s\n",src );
                return(1);
         }
        
        
        /*
         * If we have gotten here, then give/tusr subdir exists and
         * has the right properties, now just copy the file(s).
         */
                
        /*
         * make complete name of new file
         * within give/tusr directory.
         */

        if ((buf = malloc(strlen(tusr) + strlen(dname(src)) + 4)) == NULL) {
             fprintf(stderr,"give: Insufficient memory to give %s\n ",src);
             exit(3);
        }
        sprintf(buf, "%s/%s", tusr, dname(src));
        target = buf;
        pt = buf;

        /* 
         * Attempt to open source for copy.
         */
                 
        if ((from = open(src, 0)) < 0) {
                fprintf(stderr, "give: cannot open %s\n",src);
                if (buf != NULL)
                        free(buf);
                return (1);
        }
                
        /* 
         * If target exists, return.
         */
                
        if (stat(target,&ns2) != -1 ) {
                fprintf(stderr,"give: file %s exists in users give directory\n", dname(src));
                return(1);
        }
        else if (errno != ENOENT) {
                fprintf(stderr,"give: cannot give %s; give directory problem.\n",dname(src));
perror("give");
                return(1);
        }

        /* 
         * Attempt to create a target.
         */
                
        if((to = creat (target, 0666)) < 0) {
                fprintf(stderr, "give: cannot create %s\n", target);
                if (buf != NULL)
                        free(buf);
                return (1);
        }
                
        /*
         * Block copy from source to target.
         */
                 
        /*
         * Attempt to pre-allocate contiguous storage for file
         */
        tot = 0;        /* total size observed */
        asize = 0;      /* allocated size */
        truncflg = 0;   /* T if source is special; truncate when done */

        if (ISREG(ns1)) {
                /* source is a regular file --
                 * allocate space for entire file now */
                asize = ns1.st_size;
        } 
        else {
                /* source is a special file --
                 * allocate a hunk, get add'l below as needed */
                asize = OUTBLKSZ;
                truncflg++;
        }
        getspace(to,asize);
        while((ct = read(from, fbuf, BLKSIZE)) != 0) {
                tot += ct;
                if (truncflg && tot >= asize) {
                        getspace(to,OUTBLKSZ);      
                        asize += OUTBLKSZ;
                }
                if(ct < 0 || write(to, fbuf, ct) != ct) {
                        fprintf(stderr, "give: bad copy to %s\n", target);

                        /* unlink the bad file. */
                        unlink(target);
                        if (buf != NULL)
                                free(buf);
                        return (1);
                }
        }
        if (truncflg) {
              /*  trunc(to);  */    /* truncate file to actual length */
        }
                

        /* Changed to check return status from close() */
        /*      close(from), close(to);                */
        if (close(from)) {
                fprintf(stderr,"give: cannot close %s\n",src);
                if (buf != NULL)
                        free(buf);
                return(1);
        }
        if (close(to)) {
                fprintf(stderr,"give: cannot close %s\n",target);
                if (buf != NULL)
                        free(buf);
                return(1);
        }
        if (chown(pt,duid,dgid) < 0) {
                fprintf(stderr,"give: cannot complete give of %s\n",dname(src));
                (void) unlink(target);
                return(1);
        }
        if (buf != NULL)
                free(buf);
        return(0);
                
}


char * dname(char *name)
{
        register char *p;

        /* 
         * Return just the file name given the complete path.
         * Like basename(1).
         */
         
        p = name;
        
        /*
         * While there are characters left,
         * set name to start after last
         * delimiter.
         */
         
        while (*p)
                if (*p++ == DELIM && *p)
                        name = p;
        return name;
}

/*
 * Pre-allocate space for output file
 */

void getspace(int fd,long size)
{
/*      
  if (ialloc(fd,size,IA_CONT,0) < 0) {
                ialloc(fd,size,0,0);
        }
*/
}
