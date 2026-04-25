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
   dnf install nodejs -y
   echo -e "$G not installed in machine installing nodejs $W" &>> $LOG_FILE
else
   echo -e "$Y installed in machine Skipping installing nodejs $W" &>> $LOG_FILE
   exit 1
   
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

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
 VALIDATE $? "downloading the code "

cd /app 
unzip /tmp/catalogue.zip  &>>$LOG_FILE
VALIDATE $? "unziping the app folder"

npm install &>> $LOG_FILE

VALIDATE $? "npm installing::"


cp $current_directory/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE
 VALIDATE $? "copying  catalogue service" 

 systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reload " 

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "enable catalogue "
systemctl start catalogue &>> $LOG_FILE

VALIDATE $? "start catalogue "
 
 cp $current_directory/mongo.repo  /etc/yum.repos.d/mongo.repo &>> $LOG_FILE

 VALIDATE $? "copy mongo repo "

 dnf install mongodb-mongosh -y &>>$LOG_FILE

 VALIDATE $? "installing mongodb client "

 DBStatus=$(mongosh --host mongodb.devops26.sbs --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $DBStatus -lt 0 ]
then
    echo -e "$G data is not load, going to load data $W" | tee -a $LOG_FILE

    mongosh --host mongodb.devops26.sbs </app/db/master-data.js &>>$LOG_FILE
else 
     echo -e "Data is already loaded ... $Y SKIPPING $N"
fi
End_time=$(date +%s)
systemctl restart catalogue &>> $LOG_FILE
VALIDATE $? "restart  catalogue "

Total_execution_time=$(($End_time - $Start_time))

echo -e " $G Total_execution_time:: $Total_execution_time:: $W"
 






