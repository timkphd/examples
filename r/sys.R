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

sys_py<-function(command){
    x<-system(command,intern=TRUE)
    x<-paste(x, collapse = '\n')
}

