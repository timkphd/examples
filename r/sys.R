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

library('IRdisplay') 

html<-function(x){
    display_html(file=x)
}

image<-function(x){
    z<-paste('<img src="',x,'">',sep='')
    display_html(z)
}


# adapt this for local usage
srun<-function(inputs) {
    x<-sys_vec("printenv PATH")
    command="echo Could not determine MPI version "
    if (grepl("mpich",x) == TRUE ) {
        command<-"mpirun -envlist R_LIBS_USER,LD_LIBRARY_PATH,PATH -f ~/bin/both "
    }
    if (grepl("openmpi",x) == TRUE ) {
        command="mpirun -x R_LIBS_USER -x LD_LIBRARY_PATH -x PATH -hostfile ~/bin/both"
    }
    command=paste(command,inputs)
    #print(command)
    sys(command)
}

