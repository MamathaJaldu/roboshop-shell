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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disable nodejs default version"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enable nodejs 18 version"

VALIDATE $? "install nodejs" &>> $LOGFILE

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

 curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

 VALIDATE $? "Downloading user application"

 cd /app

 unzip /tmp/user.zip &>> $LOGFILE

 VALIDATE $? "unzipping application"

 npm install &>> $LOGFILE

 VALIDATE $? "install dependencies"

 cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

 VALIDATE $? "copying user service" 

 systemctl daemon-reload

 VALIDATE $? "reload user service"

 systemctl enable user &>> $LOGFILE 

 VALIDATE $? " enable user"

 systemctl start user &>> $LOGFILE

 VALIDATE $? "start user"

 cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

 VALIDATE $? "copying mango repo"

 dnf install mongodb-org-shell -y &>> $LOGFILE

 VALIDATE $? "installing mongodb client"

 mongo --host mongodb.robodevops.shop </app/schema/user.js &>> $LOGFILE

 VALIDATE $? "loading user data into mongodb"


