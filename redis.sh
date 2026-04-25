#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

USERID=$(id -u)

if [ $USERID -eq 0 ]
then
   echo -e "$G user Logged as root user:: $W" &>> $LOG_FILE
else
   echo -e "$R please log user as a root user:: $W" &>> $LOG_FILE
   exit 1
fi
 VALIDATE $? "user logged as root is "  &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$R $2 is failure $W " | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$G $2 is Sucess $W " | tee -a $LOG_FILE 
    fi

}

dnf module disable redis -y &>> $LOG_FILE

VALIDATE $? "disable  latest redis version "

dnf module enable redis:7 -y &>> $LOG_FILE

VALIDATE $? "enable  redis version of 7 "

dnf list --installed redis

if [ $? -eq 1 ]
then
   echo -e "$R redis not installed going to install  $W" &>> $LOG_FILE 
   dnf install redis -y &>> $LOG_FILE
else
   echo -e "$G redis  installed in machine :: $Y skipping::  $W" &>> $LOG_FILE
   
fi
VALIDATE $? "install redis  " &>> $LOG_FILE

#cp /redis.conf /etc/redis/redis.conf






  



