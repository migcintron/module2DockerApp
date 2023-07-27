#!/bin/bash

moduleDirName=Modulo2MiguelCintron-2
fileWebsite=chocolux.zip
originalFolderWebsite=chocolux-html
mySQLPassword=M1gu3L
phpFileToTestMySQL=index.php
containerForMySQL=MySQLMiguelCintron2
containerForApacheServer=ApacheAppMiguelCintron2
mySQLInitialDatabases="My SQL initial databases in MySQLMiguelCintron2 are: "

echo "Creating working directory..."
echo 'y' | rm -r $moduleDirName
mkdir $moduleDirName

echo "Installing Docker..."
echo "Y" | sudo apt install docker

echo "Installing Unzip..."
sudo apt install unzip

cd $moduleDirName

if [ -f "$fileWebsite" ]; then
   echo "Website template already exists."
else
   echo "Downloading website template...."
   wget https://www.free-css.com/assets/files/free-css-templates/download/page293/chocolux.zip
fi

echo "Unzipping website template..."
unzip $fileWebsite

echo "Creating a file to test MySQL connection..."
cd $originalFolderWebsite
#this is basically a php function to show mysql default databases instead of the word Yummy in the website

echo "<?php " >> $phpFileToTestMySQL
echo "function testPHP(){" >> $phpFileToTestMySQL
echo ' $cnx = new mysqli("'$containerForMySQL'","root","'$mySQLPassword'"); ' >>  $phpFileToTestMySQL
echo ' echo "'$mySQLInitialDatabases'";' >> $phpFileToTestMySQL
echo ' $res = $cnx->query("SHOW DATABASES;");' >> $phpFileToTestMySQL
echo ' while ($row = $res->fetch_array()) { echo  $row[0]."  "; } ' >> $phpFileToTestMySQL
echo ' $cnx->close();' >>  $phpFileToTestMySQL
echo " } ?>" >> $phpFileToTestMySQL

cat index.html >> index.php

echo "Replacing Yummy word for initial mysql database names..."
sed -i 's/Yummy/<?php testPHP(); ?>/g' index.php

cd ..

echo "Stopping previous Miguel Cintron Docker containers..."

sudo docker stop ApacheAppMiguelCintron
sudo docker stop MySQLMiguelCintron

echo "Creating Docker containers from docker compose file..."

sudo docker compose up -d

sudo docker exec -it $containerForApacheServer docker-php-ext-install mysqli
sudo docker exec -it $containerForApacheServer docker-php-ext-enable mysqli
sudo docker restart $containerForApacheServer

echo "Testing MySQL connection:"

wget http://localhost:8081/index.php

echo "Checking lines with mysql database names:"

cat index.php | grep "MiguelCintron2"

echo "Installation complete!"

echo "You can enter to the website in http://localhost:8081/index.php and look for MySQL initial databases names in the initial slider to check MySQL Connection"