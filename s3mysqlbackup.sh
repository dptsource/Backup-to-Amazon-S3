#!/bin/bash

# Basic variables
mysqlpass="ROOTPASSWORD"
bucket="s3://bucketname"

# Timestamps
datestamp=`date +"%Y-%m-%d"`
timestamp=`date +"%H-%M-%S"`

# List all the databases
databases=`mysql -u root -p$mysqlpass -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|mysql\)"`

# Loop the databases
for db in $databases; do

  # Define our filenames - it makes sense to keep all the tables grouped together on S3 so we can see all the tables in a single folder :-)
  filename="$datestamp-$timestamp-$db.sql.gz"
  tmpfile="/tmp/$filename"
  object="$bucket/$datestamp/$filename"

  echo -e "Dumping \e[0;34m$db\e[0m to \e[0;35m$tmpfile\e[0m..."
  mysqldump -u root -p$mysqlpass --force --opt --databases $db | gzip -c > $tmpfile

  echo -e "Moving \e[0;34m$tmpfile\e[0m to \e[0;35m$object\e[0m..."
  s3cmd put $tmpfile $object

  echo -e "Removing \e[1;31m$tmpfile\e[0m"
  rm -f $tmpfile

  echo -e "\e[1;32mDatabase: $db backed up successfully to S3\e[0m"
done;