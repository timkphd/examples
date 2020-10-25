import socket
#import fcntl
#import struct
import sys
import time


def get_ip_address(ifname):
	return "192.168.1.45"
#    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#    return socket.inet_ntoa(fcntl.ioctl(
#        s.fileno(),
#        0x8915,  # SIOCGIFADDR
#        struct.pack('256s', ifname[:15])
#    )[20:24])

def connect(message,direction):
	if direction.find("client") > -1 :
		return client(message)
	if direction.find("server") > -1 :
		return client(message)
	return "must specify either client or server"

def client():
	import os.path
	import os
	filename="/Users/tkaiser/tkaiser/ib0"
	notready=True
# while notready:
# ready=os.path.isfile(filename)
# time.sleep(0.1)
# notready= not(ready)
# f=open(filename,"r")
# ib0=f.read()
# f.close()
# os.remove(filename)
# print("try to connect to:",ib0)
	ib0="192.168.1.45"
	clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	clientsocket.connect((ib0, 45680))
	x=bytes(b"bonk")
	clientsocket.send(x)
	buf=clientsocket.recv(64)
	clientsocket.close()
	return buf


#print(client())
