import tensorflow as tf
from os import getpid
import sys
from platform import node
import horovod
import horovod.tensorflow as hvd
from time import time

def main():
    # Horovod: initialize Horovod.
    hvd.init()

    # Horovod: pin GPU to be used to process local rank (one GPU per process)
    gpus = tf.config.experimental.list_physical_devices('GPU')
    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)
    if gpus:
        tf.config.experimental.set_visible_devices(gpus[hvd.local_rank()], 'GPU')
    device = tf.device('gpu')
    print("dev ",device," running ",getpid())
    nlast=80000
    tmax=20
    startt=time()
    for n in range(1,nlast+1):
        x=[[hvd.local_rank(), -4.0], [1.0, hvd.rank()]]
        inv_x = tf.linalg.lu_matrix_inverse(*tf.linalg.lu(x))
        ones=tf.linalg.matmul(x,inv_x)
        dt=time()-startt
        if dt > tmax : 
            break
        if n < nlast :
            del x
            del inv_x
            del ones
    rate=n/dt
    rate=float(rate)
    rate=tf.constant(rate, tf.float32)
    grate=hvd.allreduce(rate, average=False)
    fname=str("rank_%d_of_%d" % (hvd.rank(),hvd.size()))
    stdout_fileno = sys.stdout
    sys.stdout=open(fname,'w')
    print("node:",node()," rank:",hvd.rank()," local rank:",hvd.local_rank()," pid:",getpid())
    print(device)
    for (lab,mat) in [["matrix",x],["inverse",inv_x],["ones",ones]] :
        print(lab)
        for i in range (0,2) :
            print("%10.3f  %10.3f" % (mat[i][0],mat[i][1]))
    print("iterations/sec: %10.1f" % (n/dt))
    print("global rate ",grate)
    sys.stdout.close()
    sys.stdout = stdout_fileno
if __name__ == '__main__':
    if len(sys.argv) == 4:
        np = int(sys.argv[1])
        hosts = sys.argv[2]
        comm = sys.argv[3]
        print('Running training through horovod.run')
        horovod.run(main, np=np, hosts=hosts, use_gloo=comm == 'gloo', use_mpi=comm == 'mpi')
    else:
        # this is running via horovodrun
        main()

