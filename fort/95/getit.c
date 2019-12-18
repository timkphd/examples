#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
size_t c_filesize(char* filename)
{
    size_t rv = 0;  // Return 0, if failure
    struct stat  file_info;

    if ( (filename != NULL) && (stat(filename,&file_info) == 0) )  //NULL check/stat() call
      rv = (size_t)file_info.st_size;  // Note: this may not fit in a size_t variable

  return rv;
}
