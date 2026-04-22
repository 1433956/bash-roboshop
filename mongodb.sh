#!/bin/bash


LOG_FOLDER="/var/log/roboshop-logs"
mkdir -p $LOG_FOLDER
LOG_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOG_FILENAME.log"

