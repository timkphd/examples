#!/usr/bin/env bash

test -e /tmp/xpmem.share && rm -f /tmp/xpmem.share
test -e /tmp/xpmem.lock && rm -f /tmp/xpmem.lock

# create TMP_SHARE_SIZE bytes defined in xpmem_test.h
for i in `seq 0 31` ; do
	#echo -n 1 >> /tmp/xpmem.share
	echo -n 0 >> /tmp/xpmem.share
done
echo 0 > /tmp/xpmem.lock

# Run the main test app
echo $LD_LIBRARY_PATH| grep /nopt/xpmem > /dev/null ; if [ $? -ne 0 ]; then export LD_LIBRARY_PATH=/nopt/xpmem/lib:$LD_LIBRARY_PATH ; fi
$PWD/xpmem_master

if [ -e "/tmp/xpmem.share" ]; then
	rm /tmp/xpmem.share
fi
if [ -e "/tmp/xpmem.lock" ]; then
	rm /tmp/xpmem.lock
fi

# Run the MPI version
srun -n 2 ./combined

