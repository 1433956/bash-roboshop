#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"

Start_time=$(date +%s)
 
LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

current_directory=$PWD
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


dnf install nginx -y &>> $LOG_FILE

VALIDATE $? "install nginx "

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "enable nginx "
systemctl start nginx  &>> $LOG_FILE
VALIDATE $? "start nginx "

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE

VALIDATE $? "removing default content "


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE

VALIDATE $? "downloading code "

cd /usr/share/nginx/html 
rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "delete nginx conf code "
unzip /tmp/frontend.zip &>> $LOG_FILE

VALIDATE $? "unzipping code "
cp $current_directory/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx &>> $LOG_FILE

VALIDATE $? "restart nginx "




   