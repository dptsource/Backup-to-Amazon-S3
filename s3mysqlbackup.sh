#!/bin/bash

# BASED ON - https://gist.github.com/2206527

# Basic variables
mysqlpass="ROOTPASSWORD"
bucket="s3://bucketname"

# Timestamp (sortable AND readable)
stamp=`date +"%s - %A %d %B %Y %H-%M-%S"`
datestamp=`date +"%Y-%m-%d"`
timestamp=`date +"%H-%M-%S"`

# List all the databases
databases=`mysql -u root -p$mysqlpass -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|mysql\)"`

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="$stamp-$db.sql.gz"
  tmpfile="/tmp/$filename"
  object="$bucket/$stamp/$filename"

  # Dump and zip
  echo -e "Dumping \e[0;34m$db\e[0m to \e[0;35m$tmpfile\e[0m..."
  mysqldump -u root -p$mysqlpass --force --opt --databases "$db" | gzip -c > "$tmpfile"

  # Upload
  echo -e "Moving \e[0;34m$tmpfile\e[0m to \e[0;35m$object\e[0m..."
  s3cmd put "$tmpfile" "$object"

  # Delete
  echo -e "Removing \e[1;31m$tmpfile\e[0m"
  rm -f "$tmpfile"

done;

# Jobs a goodun
echo -e "\e[1;32mAll done :-)\e[0m"