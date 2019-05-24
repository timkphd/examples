#!/bgsys/tools/Python-2.6/bin/python 
#####!/bgsys/drivers/V1R2M0/ppc64/tools/python/bldsrc-2.6.7/Python-2.6.7/python
import os
import sys
import platform
id=os.getpid()
name=os.uname()
print id,name,sys.argv,platform.node()
#print os.environ


