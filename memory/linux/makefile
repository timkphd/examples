#see http://man7.org/linux/man-pages/man3/malloc_info.3.html 
#    http://man7.org/linux/man-pages/man3/mallinfo.3.html
 
both:minfo mallinfo

minfo:minfo.c
	 gcc minfo.c -o minfo -lpthread

mallinfo:mallinfo.c
	gcc mallinfo.c -o mallinfo


clean:
	rm -rf minfo mallinfo *[0-9]*
