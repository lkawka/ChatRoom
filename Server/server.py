# server.py

import socket
import select
import pymysql

"""
Server commands to clients:
    MSG04user0003hey - message "hey" from user   
    
    REG1 - client is successfully registered
    REG0 - client is unsuccessfully registered
    
    LOG1 - client is successfully logged in
    LOG0 - client is unsuccessfully logged in
    
    DIS - client about to be disconnected from server
    
"""

host = '127.0.0.1'
port = 9997
socketList = []
maxTextLength = 4096
maxClientConnections = 100
coder = 'utf-8'

succssefullyRegisterd = "REG1\n".encode(coder)
unsuccessfullyRegistered = "REG0\n".encode(coder)
successfullyLoggedIn = "LOG1\n".encode(coder)
unsuccessfullyLoggedIn = "LOG0\n".encode(coder)

isLoggedIn = dict()


def getConnectionToDatabase():
    connection = pymysql.connect(host = "127.0.0.1",
                                 port = 3306,
                                 user = 'root',
                                 passwd = 'bizon',
                                 db = 'chatRoom')
    return connection


def chatServer():
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serverSocket.bind((host, port))
    serverSocket.listen(maxClientConnections)

    # add server socket object to the list of readable connections
    socketList.append(serverSocket)

    print("Server established on port " + str(port))

    while True:
        # get the list sockets which are ready to be read through select
        readyToRead, readyToWrite, inError = select.select(socketList, [], [], 0)

        for socket1 in readyToRead:
            # new connection request
            if socket1 == serverSocket:
                newClientSocket, addres = serverSocket.accept()
                socketList.append(newClientSocket)

                isLoggedIn[newClientSocket.getpeername()[1]] = False

                print("Client connected", addres)
            # message from client
            else:
                try:
                    data = socket1.recv(maxTextLength)
                except:
                    removeSocket(socket1)

                if data:
                    print("Message received: ", data)
                    processData(serverSocket, socket1, data.decode(coder))
                else:
                    removeSocket(socket1)

    serverSocket.close()
    print("Server shut down")


def processData(serverSocket, sender, data):
    if data[0:3] == 'REG':
        # Registration request
        # 'REG' + 2 digit username length + username + 2 digit password length + password + 2 digit email length + email
        # example: REG04User05maslo13user@user.com
        try:
            usernameLength = int(data[3:5])
            username = data[5:5 + usernameLength]

            passwordLength = int(data[5 + usernameLength:7 + usernameLength])
            password = data[7 + usernameLength:7 + usernameLength + passwordLength]

            emailLength = int(data[7 + usernameLength + passwordLength:9 + usernameLength + passwordLength])
            email = data[9 + usernameLength + passwordLength:9 + usernameLength + passwordLength + emailLength]

            registrationRequest(sender, username, password, email)
        except:
            print("Unable to process data")
    elif data[0:3] == 'LOG':
        # Log in request
        # 'LOG' + 2 digit username length + username + 2 digit password length + password

        try:
            usernameLength = int(data[3:5])
            username = data[5:5 + usernameLength]

            passwordLength = int(data[5 + usernameLength:7 + usernameLength])
            password = data[7 + usernameLength:7 + usernameLength + passwordLength]

            logInRequest(sender, username, password)
        except:
            print("Unable to process data")
    elif data[0:3] == 'MSG':
        # New message
        # 'MSG' + 2 digit username length + username + 4 digit message length + message
        data += "\n"

        newMessage(serverSocket, sender, data)
    elif data[0:3] == 'OUT':
        # Client logged out
        isLoggedIn[sender.getpeername()[1]] = False

    else:
        print("Unable to process data")


def registrationRequest(sender, username, password, email):
    try:
        databaseConnection = getConnectionToDatabase()
        cursor = databaseConnection.cursor()

        sql = "Insert into users (username, password, email) values (%s, %s, %s)"
        cursor.execute(sql, (username, password, email))

        databaseConnection.commit()

        print(username, "successfully registered")
        sender.send(succssefullyRegisterd)
    except:
        print("Failed to register ", username)
        sender.send(unsuccessfullyRegistered)

    databaseConnection.close()


def logInRequest(sender, username, password):
    try:
        databaseConnection = getConnectionToDatabase()
        cursor = databaseConnection.cursor()

        sql = "Select username, password from users where username=%s and password=%s"
        rowsCount = cursor.execute(sql, (username, password))
        databaseConnection.commit()
    except:
        print("Failed to log in")
        sender.send(unsuccessfullyLoggedIn)

    if (rowsCount > 0):
        for row in cursor:
            print(row[0], "successfully logged in")
            isLoggedIn[sender.getpeername()[1]] = True
            sender.send(successfullyLoggedIn)
    else:
        print('Wrong username and/or password')
        sender.send(unsuccessfullyLoggedIn)

    databaseConnection.close()


def newMessage(serverSocket, sender, message):
    if(isLoggedIn[sender.getpeername()[1]]):
        print("Broadcasting: ", message)

        broadcast(serverSocket, sender, message)
    else:
        print("Message from not logged in client")


def broadcast(serverSocket, sender, message):
    for socket1 in socketList:
        if socket1 != serverSocket and socket1 != sender:
            try:
                socket1.send(message.encode(coder))
            except:
                removeSocket(socket1)


def removeSocket(socket1):
    print(socket1.getpeername()[1], "disconnected")
    del isLoggedIn[socket1.getpeername()[1]]

    socket1.close()
    if socket1 in socketList:
        socketList.remove(socket1)


chatServer()
