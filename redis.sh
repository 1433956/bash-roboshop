#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/roboshop-logs"
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

USERID=$(id -u)

if [ $USERID -eq 0 ]
then
   echo -e "$G user Logged as root user:: $W" &>> $LOG_FILE
else
   echo -e "$R user Logged as root user:: $W" &>> $LOG_FILE
   exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$R $2 is failure $W " | tee -a $LOG_FILE
    else
       echo -e "$G $2 is Sucess $W " | tee -a $LOG_FILE 
    fi

}





  



