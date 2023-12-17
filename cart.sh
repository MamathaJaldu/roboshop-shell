#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F:%H:%M:%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disable nodejs default version"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

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

 curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

 VALIDATE $? "Downloading cart application"

 cd /app

 unzip -o /tmp/cart.zip &>> $LOGFILE

 VALIDATE $? "unzipping application"

 npm install &>> $LOGFILE

 VALIDATE $? "install dependencies"

 cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

 VALIDATE $? "copying cart service file"

 systemctl daemon-reload

 VALIDATE $? "reload cart service"

 systemctl enable cart &>> $LOGFILE 

 VALIDATE $? " enable cart"

 systemctl start cart &>> $LOGFILE

 VALIDATE $? "start cart"



