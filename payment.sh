#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F:%H:%M:%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$2...$R FAILED $N"
       exit 1
    else
       echo -e "$2...$R success $N"
    fi     
}

if [ $ID -ne 0 ]
then
   echo "ERROR: Please login with root user"
   exit 1
else
   echo "you login with root user"
fi  

dnf install python36 gcc python3-devel -y

VALIDATE $? "installing python"

id roboshop  # if username roboshop does not exist then it is failure

if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "user roboshop added"
else
   echo -e "user already exist $Y skipping $N"

 fi

mkdir -p /app &>> $LOGFILE

 VALIDATE $? "creating directory"

 curl -o /tmp/payment.zip  https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

 VALIDATE $? "Downloading payment application"

 cd /app

 unzip -o /tmp/payment.zip &>> $LOGFILE

 VALIDATE $? "unzipping application"

 pip3.6 install -r requirements.txt

 VALIDATE $? "installing dependencies"

 cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

 VALIDATE $? "copying payment service"

 systemctl daemon-reload

 VALIDATE $? "reload service"

 systemctl enable payment 

 VALIDATE $? "enable payment service"

 systemctl start payment

 VALIDATE $? "start payment service"



