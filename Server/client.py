import socket
import time
import pymysql

host = '127.0.0.1'
port = 9997

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))

time.sleep(5)



msg = "LOG03tom05abcde"

s.send(msg.encode('ascii'))

print("msg sent")

s.close()




