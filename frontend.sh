#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"

Start_time=$(date +%s)
 
LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"


USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
   echo -e "$R please logg user as root user $W" &>> $LOG_FILE
   exit 1
else
   echo -e "$G  logged  user as root user $W" &>> $LOG_FILE
fi

VALIDATE(){

     if [ $1 -ne 0 ]
   then 
       echo -e "$R $2 is Failure:: $W" | tee -a $LOG_FILE
       exit 1
   else
      echo -e "$G $2 is Success:: $W" | tee -a $LOG_FILE
   fi
}

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "disabling nginx module"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "enable nginx module"

dnf list installed nginx 

if [ $? -ne 0 ]
then 
    echo -e "$R nginx is not installed $W" &>> $LOG_FILE
    dnf install nginx -y &>> $LOG_FILE
else  
    echo -e "$G nginx is installed:: $Y skipping :: $W" &>> $LOG_FILE
    exit 1
fi


   