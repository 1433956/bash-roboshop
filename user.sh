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
current_directory=$PWD

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
       echo -e "$R $2 is Failure:: $W" | tee -a $LOG_FILE
       exit 1
   else
      echo -e "$G $2 is Success:: $W" | tee -a $LOG_FILE
   fi

}

dnf module disable nodejs -y  &>> $LOG_FILE

VALIDATE $? "disabling the nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "enable  the nodejs version of 20"

dnf list --installed nodejs &>> $LOG_FILE
if [ $? -ne 0 ]
then 
   dnf install nodejs -y &>> $LOG_FILE
   echo -e "$G not installed in machine installing nodejs $W" &>> $LOG_FILE
else
   echo -e "$Y installed in machine Skipping installing nodejs $W" &>> $LOG_FILE
   
   
fi
     
VALIDATE $? "installing  nodejs"

#create system user 

user=$(id roboshop)

if [ $? -eq 0 ]
then 
   echo -e "$Y system user is created skiping user creation::$user $W" | tee -a $LOG_FILE
   
else
   echo -e "$G system user not created, Creting system user:: $user $W" | tee -a $LOG_FILE
   
   useradd --system --home /app --shell /sbin/nologin  --comment "creating system user" roboshop
   exit 1
fi

mkdir -p /app

VALIDATE $? "creating directory for app"

rm -rf /app/*

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
 VALIDATE $? "downloading the code "

cd /app 
unzip /tmp/user.zip  &>>$LOG_FILE
VALIDATE $? "unziping the app folder"

npm install &>> $LOG_FILE

VALIDATE $? "npm installing::"


cp $current_directory/user.service /etc/systemd/system/user.service &>> $LOG_FILE
 VALIDATE $? "copying  user service" 

 systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reload " 

systemctl enable user &>> $LOG_FILE
VALIDATE $? "enable user "
systemctl start user &>> $LOG_FILE

