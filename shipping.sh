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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "install maven"

id roboshop &>> $LOGFILE

if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "user roboshop added"
else
   echo "-e "user already exist $Y skipping $N""
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "created app directory"

cd /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "downloading shipping"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "mvn downloading dependencies and build the code"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming the jar file"

cp  /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying the shipping service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reload the service"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "install mysql"

mysql -h mysql.robodevops.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restart shipping"






