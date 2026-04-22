#!/bin/bash


LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"
 echo $LOG_FILE
G="\e[31m"
R="\e[32m"
Y="\e[33m"
W="\e[0m"

USERID=$(id -u)

#check user is logged as root user

if [ $? -ne 0 ]
then
   echo -e "$R please log user as root user::  $W" | tee -a $LOG_FILE
   exit 1
else 
    echo -e "$G logged as a root user:: $W " | tee -a $LOG_FILE
fi

VALIDATE(){
   if [ $1 -ne 0 ]
   then 
       echo -e "$R $2 is Failure:: $W" | tee -a $LOG_FILE
   else
      echo -e "$G $2 is Success:: $W" | tee -a $LOG_FILE
   fi

}

cp  mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y
VALIDATE $? "installing mongodb"
systemctl enable mongod
VALIDATE $? "enable  mongodb"
systemctl start mongod
VALIDATE $? "start mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "channging mongod conf "

systemctl restart mongod
VALIDATE $? "restart mongodb"


 

