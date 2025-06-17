#!/usr/bin/env python3

# ln -s client.py server.py
# chmod 755 client.py

#on kestrel
# ./client.py 10.15.0.161
#on my laptop
# ./server.py
import socket
import sys
from time import asctime,sleep

prog=sys.argv[1]
PORT = 20000  
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
				data=data.strip(b'\x00')
				print("on server:",data)
				sleep(1)
            
if(prog.find("clie")> -1):
	HOST = prog=sys.argv[2]
	#HOST =sys.argv[2]
	with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
		s.connect((HOST, PORT))
		for i in range(0,count):
			data = s.recv(1024)
			data=data.strip(b'\x00')
			sleep(1)
			s.sendall(bytes(asctime(),'utf-8'))
			print('on client:', repr(data))

