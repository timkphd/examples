# show how these work
# "source" this in a notebook
# 
source("mysys.R")
source("tymer.R")
sys("cat runsystymer.R")
ls()
html("readme.html")
imbase("images/Rstuff")
nextim()
sys("ls -lt")
z<-sys_df("srun -n 8 ./bcast.R")
z
tymer("begin")
srun("-n 4 ./flower.R")
tymer("end")
print(sprintf("%4.4d",12))
nextim(51)
for (i in 1:3) {
    nextim()
    Sys.sleep(3)
}
