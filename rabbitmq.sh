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
       echo -e "$R $2 is Failure:: $W" | tee -a $LOG_FILE
       exit 1
   else
      echo -e "$G $2 is Success:: $W" | tee -a $LOG_FILE
   fi

}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOG_FILE
VALIDATE $? "copy  rabbitmq repo"

dnf list --installed rabbitmq-server &>> $LOG_FILE

if [ $? -ne 0 ]
then
   echo -e "$R rabbitmq-server not installed going to install  $W" &>> $LOG_FILE 
   dnf install rabbitmq-server -y &>> $LOG_FILE
   VALIDATE $? "installing"
else
   echo -e "$G rabbitmq-server  installed in machine :: $Y skipping::  $W" &>> $LOG_FILE
   VALIDATE $? "Not installing"
fi

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "enable rabbitmq-server"
systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "start rabbitmq-server"

echo -e "$G please enter psswd for rabbitmq::"
read -s rabbitmqpwd
rabbitmqctl add_user roboshop $rabbitmqpwd $LOG_FILE
VALIDATE $? "add user to  rabbitmq-server"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" $LOG_FILE
VALIDATE $? "set_permissions to  rabbitmq-server"

End_time=$(date +%s)

Total_execution_time=$(($End_time - $Start_time ))
 
 echo -e "$G total execution::$W $Total_execution_time"

