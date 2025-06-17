all: c_s vc_s

clean:
	rm -rf c_s vc_s

c_s: client.c
	cc client.c -o c_s

vc_s: vclient.c
	cc vclient.c -o vc_s

SERVER:=10.15.0.161
runs: all
	 for x in 0 1 2 ; do for y in client.py c_s vc_s; do echo $$x $$y; eval ./$$y server              ; sleep 5 ; done ;done
	 
runc: all
	for y in client.py c_s vc_s ; do for x in 0 1 2 ; do echo $$x $$y; eval ./$$y client ${SERVER} ; sleep 7 ; done ;done
