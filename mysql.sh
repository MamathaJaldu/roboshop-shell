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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disable mysql"

cp /home/centos/roboshop-shell/mysql.repo  /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copying sql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing  mysql"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enable mysqld"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enable mysqld"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting mysql root password"










