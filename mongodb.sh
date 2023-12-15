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

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "install mongodb"

systemctl enable mongod  &>> $LOGFILE

VALIDATE $? "enable mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to mongodb"

systemctl restart mongod  &>> $LOGFILE

VALIDATE $? "restart mongodb"

