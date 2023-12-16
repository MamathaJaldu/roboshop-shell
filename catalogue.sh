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

VALIDATE $? "disable default nodejs version"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enable nodejs 18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "install nodejs"

id roboshop  # if username roboshop does not exist then it is failure

if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "user roboshop added"
else
   echo -e "user already exist $Y skipping $N"

 fi

 mkdir -p /app

 VALIDATE $? "creating directory"

 curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

 VALIDATE $? "Downloading catalogue application"

 cd /app

 unzip -o /tmp/catalogue.zip &>> $LOGFILE

 VALIDATE $? "unzipping application"

 npm install &>> $LOGFILE

 VALIDATE $? "install dependencies"

 cp /home/centos/roboshop-shell/catalogue.service  /etc/systemd/system/catalogue.service &>> $LOGFILE

 VALIDATE $? "copying catalogue service"

 systemctl daemon-reload &>> $LOGFILE

 VALIDATE $? "reload catalogue service"

 systemctl start catalogue &>> $LOGFILE

 VALIDATE $? "starting catalogue service"

 cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

 VALIDATE $? "copying mongodb repo"

 dnf install mongodb-org-shell -y &>> $LOGFILE

 VALIDATE $? "install mongodb"

 mongo --host mongodb.robodevops.shop </app/schema/catalogue.js &>> $LOGFILE

 VALIDATE $? "loading catalogue data into mongodb"