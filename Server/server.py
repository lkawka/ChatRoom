# server.py

import sys
import socket
import select
import pymysql


host = '127.0.0.1'
port = 9997
socketList = []
maxTextLength = 4096
maxClientConnections = 100

isLoggedIn = dict()


def getConnectionToDatabase():
    connection = pymysql.connect(host=host,
                                 port=3306,
                                 user='root',
                                 passwd='bizon',
                                 db='chatRoom')
    return connection


def chatServer():
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serverSocket.bind((host, port))
    serverSocket.listen(maxClientConnections)

    #add server socket object to the list of readable connections
    socketList.append(serverSocket)

    print("Server established on port " + str(port))

    while True:
        # get the list sockets which are ready to be read through select
        readyToRead, readyToWrite, inError = select.select(socketList, [], [], 0)

        for socket1 in readyToRead:
            #new connection request
            if socket1 == serverSocket:
                newClientSocket, addres = serverSocket.accept()
                socketList.append(newClientSocket)

                print("Client connected", addres)
            #message from client
            else:
                print("socket: ", socket1.getpeername()[1])
                try:
                    data = socket1.recv(maxTextLength)
                except:
                    removeSocket(socket1)

                if data:
                    print("Message received: ", data)
                    processData(serverSocket, socket1, data)
                else:
                    removeSocket(socket1)

    serverSocket.close()
    print("Server shut down")


def processData(serverSocket, sender, data):
    if data[0:3] == b'REG':
        #Registration request
        #'REG' + 2 digit username length + username + 2 digit password length + password + 2 digit email length + email
        #example: REG04User05maslo13user@user.com

        usernameLength = int(data[3:5])
        username = data[5:5+usernameLength]

        passwordLength = int(data[5+usernameLength:7+usernameLength])
        password = data[7+usernameLength:7+usernameLength+passwordLength]

        emailLength = int(data[7+usernameLength+passwordLength:9+usernameLength+passwordLength])
        email = data[9+usernameLength+passwordLength:9+usernameLength+passwordLength+emailLength]

        registrationRequest(sender, username, password, email)
    elif data[0:3] == b'LOG':
        #Log in request
        #'LOG' + 2 digit username length + username + 2 digit password length + password

        usernameLength = int(data[3:5])
        username = data[5:5 + usernameLength]

        passwordLength = int(data[5 + usernameLength:7 + usernameLength])
        password = data[7 + usernameLength:7 + usernameLength + passwordLength]

        logInRequest(sender, username, password)
    elif data[0:3] == b'MSG':
        #New message
        #'MSG' + 2 digit username length + username + 4 digit message length + message

        newMessage(serverSocket, sender, data)
    else:
        print("Unable to procces data")


def registrationRequest(sender, username, password, email):
    # basic version, doesn't notify client if registration unsuccessful
    try:
        databaseConnection = getConnectionToDatabase()
        cursor = databaseConnection.cursor()

        sql = "Insert into users (username, password, email) values (%s, %s, %s)"
        cursor.execute(sql, (username, password, email))

        print("Registration successful for ", username)
    except:
        print("Registration failed for ", username)
    finally:
        databaseConnection.close()


def logInRequest(sender, username, password):
    try:
        databaseConnection = getConnectionToDatabase()
        cursor = databaseConnection.cursor()

        sql = "Select username, password from users where username=%s and password=%s"
        rowsCount = cursor.execute(sql, (username, password))

        print("description: ", cursor.description)
    except:
        print("Failed to log in")
        databaseConnection.close()
        return

    if (rowsCount > 0):
        for row in cursor:
            print(row[0], "successfully logged in")
            isLoggedIn[sender.getpeername()[1]] = True
    else:
        print('Wrong username and/or password')

    databaseConnection.close()

def newMessage(serverSocket, sender, message):
    if(sender.getpeername()[1] in isLoggedIn):
        if(isLoggedIn[sender.getpeername()[1]]):
            broadcast(serverSocket, sender, message)
            print("Broadcasting: ", message)

def broadcast(serverSocket, sender, message):
    for socket1 in socketList:
        if socket1 != serverSocket and socket1 != sender:
            try:
                socket1.send(message)
            except:
                removeSocket(socket1)


def removeSocket(socket1):
    print("One connection lost")
    del isLoggedIn[socket1.getpeername()[1]]
    socket1.close()
    if socket1 in socketList:
        socketList.remove(socket1)


chatServer()