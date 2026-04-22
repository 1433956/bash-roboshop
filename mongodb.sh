#!/bin/bash


LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

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
    echo -e "$G looged as a root user:: $W " | tee -a $LOG_FILE
fi

