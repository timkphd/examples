"""
Example of using fcntl.flock for locking file. Some code inspired by filelock module.
"""
# https://gist.githubusercontent.com/jirihnidek/430d45c54311661b47fb45a3a7846537/raw/917c07d27adf897b408a51a44199b6742b8f4b45/flock_example.py
import os
import fcntl
import time


def acquire(lock_file):
    open_mode = os.O_RDWR | os.O_CREAT | os.O_TRUNC
    fd = os.open(lock_file, open_mode)

    pid = os.getpid()
    lock_file_fd = None
    
    timeout = 5.0
    start_time = current_time = time.time()
    while current_time < start_time + timeout:
        try:
            # The LOCK_EX means that only one process can hold the lock
            # The LOCK_NB means that the fcntl.flock() is not blocking
            # and we are able to implement termination of while loop,
            # when timeout is reached.
            # More information here:
            # https://docs.python.org/3/library/fcntl.html#fcntl.flock
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except (IOError, OSError):
            pass
        else:
            lock_file_fd = fd
            break
        print(f'  {pid} waiting for lock')
        time.sleep(1.0)
        current_time = time.time()
    if lock_file_fd is None:
        os.close(fd)
    return lock_file_fd


def release(lock_file_fd):
    # Do not remove the lockfile:
    #
    #   https://github.com/benediktschmitt/py-filelock/issues/31
    #   https://stackoverflow.com/questions/17708885/flock-removing-locked-file-without-race-condition
    fcntl.flock(lock_file_fd, fcntl.LOCK_UN)
    os.close(lock_file_fd)
    return None


def main():
    pid = os.getpid()
    print(f'{pid} is waiting for lock')
    
    fd = acquire('myfile.lock')

    if fd is None:
        print(f'ERROR: {pid} lock NOT acquired')
        return -1

    print(f"{pid} lock acquired...")
    file1 = open("myfile.txt", "a")
    file1.write(str(pid)+"\n")
    file1.close()
    time.sleep(0.10)
    release(fd)
    print(f"{pid} lock released")    


# You can run it using: python ./flock_example.py & python ./flock_example.py
if __name__ == '__main__':
    main()

    
