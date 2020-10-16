#PYTHON_START
# LD_PRELOAD=spam.cpython-38-x86_64-linux-gnu.so python
import spam

def loop2(base,n):
	z=""
	for i in range(1,10000):
		z=z+"1234"
	y=spam.stack_count_usage(base)
	x=spam.current()
	print("stack inside %d %d %d %d "%(x,y,n,base))
	n=n+1
	if(n < 10):
		loop2(base,n)
		y=spam.stack_count_usage(base)
		x=spam.current()
		print("unwinding %d %d %d %d" % (x,y,n,base))

base=spam.stack_count_clear()
loop2(base,0)
#PYTHON_END
