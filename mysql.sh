#!/bin/bash
 Start_time=$(date +%s)
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

dnf list --installed mysql-server &>> $LOG_FILE

if [ $? -ne 0 ]
then
   echo -e "$R mysql not installed going to install  $W" &>> $LOG_FILE 
   dnf install mysql-server -y &>> $LOG_FILE
else
   echo -e "$G mysql  installed in machine :: $Y skipping::  $W" &>> $LOG_FILE
   
fi

VALIDATE $? "mysql installation is"  &>> $LOG_FILE

systemctl enable mysqld   &>> $LOG_FILE
VALIDATE $? "enable mysql "  &>> $LOG_FILE

systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "start mysql "  &>> $LOG_FILE

echo -e "$G pleae enter mysql root psswd::$W"
Read -s rootpasswd
mysql_secure_installation --set-root-pass $rootpasswd