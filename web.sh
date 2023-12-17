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

dnf install nginx -y

VALIDATE $? "installing nginx"

systemctl enable nginx

VALIDATE $? enable nginx

systemctl start nginx

VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "remove default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "downloading web application"

cd /usr/share/nginx/html

VALIDATE $? "change directory to html"

unzip /tmp/web.zip

VALIDATE $? "unzip web application"

cp  /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx 

VALIDATE $? "restart nginx"

