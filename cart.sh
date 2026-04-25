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

user=$(id roboshop) &>> $LOG_FILE

if [ $? -eq 0 ]
then 
   echo -e "$Y system user is created skiping user creation::$user $W" | tee -a $LOG_FILE
   
else
   echo -e "$G system user not created, Creting system user:: $user $W" | tee -a $LOG_FILE
   
   useradd --system --home /app --shell /sbin/nologin  --comment "creating system user" roboshop
   
fi

mkdir -p /app

VALIDATE $? "creating directory for app"

rm -rf /app/*

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
 VALIDATE $? "downloading the code "

cd /app 
unzip /tmp/cart.zip  &>>$LOG_FILE
VALIDATE $? "unziping the app folder"

npm install &>> $LOG_FILE

VALIDATE $? "npm installing::"


cp $current_directory/cart.service /etc/systemd/system/cart.service &>> $LOG_FILE
 VALIDATE $? "copying  cart service" 

 systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reload " 

systemctl enable cart &>> $LOG_FILE
VALIDATE $? "enable cart "
systemctl start cart &>> $LOG_FILE

