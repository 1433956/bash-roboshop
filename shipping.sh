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


dnf list --installed maven &>> $LOG_FILE
if [ $? -ne 0 ]
then 
   dnf install maven -y &>> $LOG_FILE
   echo -e "$G not installed in machine installing maven $W" &>> $LOG_FILE
else
   echo -e "$Y installed in machine Skipping installing maven $W" &>> $LOG_FILE
   
   
fi
     
VALIDATE $? "installing  maven"

#create system user 

user=$(id roboshop)

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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
 VALIDATE $? "downloading the code "

cd /app 
unzip /tmp/shipping.zip  &>>$LOG_FILE
VALIDATE $? "unziping the app folder"

mvn clean package &>> $LOG_FILE

VALIDATE $? "maven package installing::"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "renaming shipping jar file::"

cp $current_directory/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
 VALIDATE $? "copying  shipping service" 

 systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reload " 

systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "enable shipping  service "
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "start shipping service  "

echo -e "$G pleae enter mysql root psswd::$W"
read -s rootpasswd

dnf list --installed mysql &>> $LOG_FILE
if [ $? -eq 1 ]
then 
   dnf install mysql -y &>> $LOG_FILE
   echo -e "$G not installed in machine installing mysql $W" &>> $LOG_FILE
else
   echo -e "$Y installed in machine Skipping installing mysql $W" &>> $LOG_FILE
   VALIDATE $? "alreday insatlled, Skipping installing mysql is "
   
fi 

VALIDATE $? "install mysql client in shipping client " &>> $LOG_FILE

mysql -h mysql.devops26.sbs -uroot -p$rootpasswd -e 'use cities'  &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo $R data is not loaded.. $Y Data loading $W" &>> $LOG_FILE
    mysql -h mysql.devops26.sbs -uroot -p$rootpasswd < /app/db/schema.sql &>> $LOG_FILE
    mysql -h mysql.devops26.sbs -uroot -p$rootpasswd < /app/db/app-user.sql  &>> $LOG_FILE
    mysql -h mysql.devops26.sbs -uroot -p$rootpasswd < /app/db/master-data.sql &>> $LOG_FILE
    VALIDATE $? "data loaded is "
else
   echo $G data is  loaded.. $Y Data loading is skipped:: $W" &>> $LOG_FILE
   VALIDATE $? "data loadeding skipped "
fi


systemctl restart shipping
VALIDATE $? "restart shipping service  "

End_time=$(date +%s)

Total_execution_time=$(($End_time - $Start_time))

echo -e " $G Total_execution_time:: $Total_execution_time:: $W"
 

