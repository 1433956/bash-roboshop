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


dnf list --installed python3 gcc python3-devel &>> $LOG_FILE
if [ $? -ne 0 ]
then 
   dnf install python3 gcc python3-devel -y &>> $LOG_FILE
   echo -e "$G not installed in machine installing python3 $W" &>> $LOG_FILE
else
   echo -e "$Y installed in machine Skipping installing python3 $W" &>> $LOG_FILE
   
   
fi
     
VALIDATE $? "installing  python3"

#create system user 

user=$(id roboshop)

if [ $? -eq 0 ]
then 
   echo -e "$Y system user is created skiping user creation::$user $W" | tee -a $LOG_FILE
   
else
   echo -e "$G system user not created, Creting system user:: $user $W" | tee -a $LOG_FILE
   
   useradd --system --home /app --shell /sbin/nologin  --comment "creating system user" roboshop
   
fi

mkdir -p /app &>>$LOG_FILE

VALIDATE $? "creating directory for app"

rm -rf /app/* &>>$LOG_FILE

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
 VALIDATE $? "downloading the code "

cd /app 
unzip /tmp/payment.zip  &>>$LOG_FILE
VALIDATE $? "unziping the app folder"

pip3 install -r requirements.txt &>>$LOG_FILE

VALIDATE $? "download the dependencies"

cp $current_directory/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE

VALIDATE $? "copying  payment service" 

 systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reload " 

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "enable payment "
systemctl start payment &>> $LOG_FILE

End_time=$(date +%s)

Total_execution_time=$(($End_time - $Start_time))

echo -e " $G Total_execution_time:: $Total_execution_time:: $W"
 

