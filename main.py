import smtplib
import re 

from time import sleep as s
from datetime import datetime

def check(regex,email):   
    if(re.search(regex,email)):   
        return True
    else:   
        return False
  
def reader(filename) :
    try :
        X = open(filename,'r')
        G = X.read()
        X.close()
        return G
    except :
        print("Incorrect File Name")

def sendmail(email,password,recieve,message):
    server = smtplib.SMTP(host="smtp.gmail.com", port=587)
    server.starttls()
    try :
        server.login(email, password)
    except :
        print("Wrong Logins")
    server.sendmail(email,recieve, message)
    server.quit()
    print("Email Sent Successfully")

def messagesplit(message) :
    message = message.split()
    print(message)
    
def main() :
    
    regex = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    # system("color 2")
    senderemail = "coalproject8@gmail.com"
    senderpassword = "coalabcd123"
    
    infile = "emailfile.txt"
    previousEmail = ""
    previousBody = ""
    while(True) :
        
        message = reader(infile)
        s(5)
        
        if (len(message) != 0):
            message = message.split()
            recieveremail = message[0]
            recieveremail = recieveremail.strip()
            print(recieveremail)
            if (check(regex,recieveremail) == False) :
                print("Invalid Email !")
            else :    
                message.remove(recieveremail)
                recieveremail = recieveremail.replace("\x00", "")
                message = " ".join(message)
                # s = strings.Replace(s, "\x00", "", -1)
                message = message.replace("\x00", "")
                message = message.strip()
                if (previousBody != message and previousEmail != recieveremail):
                    previousBody = message
                    previousEmail = recieveremail
                    print(message)
                    sendmail(senderemail,senderpassword,recieveremail,message)
                else:
                    continue
        else :
            print(message)
            print("Empty File ! ")
    # system("cd C:/")
    # system("dir /s /o")
main()