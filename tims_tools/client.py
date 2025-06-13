#!/usr/bin/env python3

# ln -s cs.py client.ps
# ln -s cs.py server.py
# chmod 755 cs.py

#on kestrel
# ./client.ps 10.15.0.161
#on my laptop
# ./server
import socket
import sys
from time import asctime,sleep

prog=sys.argv[0]
PORT = 65432  
count=10      
if(prog.find("serv")> -1):
	with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
		HOST = "0.0.0.0"
		s.bind((HOST, PORT))
		s.listen()
		conn, addr = s.accept()
		with conn:
			for i in range(0,count):
				conn.sendall(bytes(asctime(),'utf-8'))
				data = conn.recv(1024)
				print("on server:",data)
				sleep(1)
            
if(prog.find("clie")> -1):
	HOST = prog=sys.argv[1]
	with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
		s.connect((HOST, PORT))
		for i in range(0,count):
			data = s.recv(1024)
			sleep(1)
			s.sendall(bytes(asctime(),'utf-8'))
			print('on client:', repr(data))

