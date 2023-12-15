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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "install rpm file for redis"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "enable redis 6.2 version" 

dnf install redis -y &>> $LOGFILE

VALIDATE $? "install redis"

sed -i 's/127.0.0.0/0.0.0.0/g'  /etc/redis/redis.conf

VALIDATE $? "Allowing remote connectios"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "enabling redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "starting redis"