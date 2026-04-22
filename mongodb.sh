#!/bin/bash

 Start_time=$(date +%s)
 
LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

USERID=$(id -u)

#check user is logged as root user

if [ $? -ne 0 ]
then
   echo -e "$R please log user as root user::  $W" &>> $LOG_FILE
   exit 1
else 
    echo -e "$G logged as a root user:: $W " &>> $LOG_FILE
fi

VALIDATE(){
   if [ $1 -ne 0 ]
   then 
       echo -e "$R $2 is Failure:: $W" &>> $LOG_FILE
       exit 1
   else
      echo -e "$G $2 is Success:: $W" &>> $LOG_FILE
   fi

}

cp  mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "installing mongodb"
systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "enable  mongodb"
systemctl start mongod &>> $LOG_FILE
VALIDATE $? "start mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf 
VALIDATE $? "channging mongod conf "

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "restart mongodb"

End_time=$(date +%s)

Total_execution_time=$(($End_time - $Start_time ))
 
 echo $Total_execution_time

