#!/usr/bin/env Rscript
#'shorcuts for system command
#' sys("command")     - cat output 
#' sys_vec("command") - return as a list
#' sys_vec("command") - return as a list
#' sys_py("command")  - return as a python like list
#' srun("command"     - srun

sys<-function(command){
    x<-system(command,intern=TRUE)
    for (i in 0:length(x)) {
        cat(x[i])
        cat("\n")
    }
}

sys_vec<-function(command){
    x<-system(command,intern=TRUE)
}

sys_df<-function(command){
    x<-system(command,intern=TRUE)
    x<-data.frame(x)
}

sys_py<-function(command){
    x<-system(command,intern=TRUE)
    x<-paste(x, collapse = '\n')
}


# adapt this for local usage
srun<-function(inputs) {
    x<-sys_vec("printenv PATH")
    command<-"echo Could not determine MPI version "
    if (grepl("mpich",x) == TRUE ) {
        command<-"mpirun -envlist R_LIBS_USER,LD_LIBRARY_PATH,PATH -f ~/bin/both "
    }
    if (grepl("openmpi",x) == TRUE ) {
        command<-"mpirun -x R_LIBS_USER -x LD_LIBRARY_PATH -x PATH -hostfile ~/bin/both"
    }
    command<-paste(command,inputs)
    #command<-paste("srun ",inputs)
    #print(command)
    sys(command)
}

rupahshbbf<<-0
uiqsagvsmu<<-"Rstuff"

library('IRdisplay') 

html<-function(x){
    display_html(file=x)
}

image<-function(x){
    z<-paste('<img src="',x,'">',sep='')
    display_html(z)
}

imreport<-function() {
    return(c(uiqsagvsmu,rupahshbbf))
}
imbase<-function(p){
    if (missing(p)) {
       uiqsagvsmu<<-"Rstuff"
    }
    else {
        uiqsagvsmu<<-p
    }
  return(uiqsagvsmu)
}

nextim<-function(j){
    if (missing(j)) {
        rupahshbbf<<-rupahshbbf+1
    } else {
        if (j < 0) {
            rupahshbbf<<-rupahshbbf+j
        }
        else {
            rupahshbbf<<-j
        }
    }
    file<-sprintf("%s.%3.3d.jpeg",uiqsagvsmu,rupahshbbf)
    image(file)
    return(file)
    }

# work in progress puts out junk along with sound
wav<-function(file="out.wav",type="wav"){
    s<-'<!DOCTYPE html>
<html>
<body>
<audio controls autoplay>
  <source src="FILE" type="audio/KIND">
  Your browser does not support the audio element.
</audio>
</body>
</html>
'
z<-sub("FILE",file,s)
z<-sub("KIND",type,z)
    display_html(z)
}


