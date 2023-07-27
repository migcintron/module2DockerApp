#!/bin/bash

moduleDirName=Modulo2MiguelCintron
containerForApacheServer=ApacheAppMiguelCintron
containerForMySQL=MySQLMiguelCintron
fileWebsite=chocolux.zip
originalFolderWebsite=chocolux-html
mySQLPassword=M1gu3L
phpFileToTestMySQL=index.php
networkName=NetworkMiguelCintron
mySQLInitialDatabases="My SQL initial databases in MySQLMiguelCintron are: "

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
echo ' $res = $cnx->query("SHOW DATABASES;");' >> $phpFileToTestMySQL
echo ' echo "'$mySQLInitialDatabases'";' >> $phpFileToTestMySQL
echo ' while ($row = $res->fetch_array()) { echo  $row[0]."  "; } ' >> $phpFileToTestMySQL
echo ' $cnx->close();' >>  $phpFileToTestMySQL
echo " } ?>" >> $phpFileToTestMySQL

cat index.html >> index.php

echo "Replacing Yummy word for my sql initial databases names"

sed -i 's/Yummy/<?php testPHP(); ?>/g' index.php

cd ..

echo "Pulling Docker images..."
sudo docker pull php:8.0-apache
sudo docker pull mysql:8.0

echo "Stopping and removing docker containers if they already exists..."
sudo docker stop $containerForApacheServer
sudo docker rm $containerForApacheServer
sudo docker stop $containerForMySQL
sudo docker rm $containerForMySQL

echo "Creating network and volume for containers..."
sudo docker network create $networkName
echo "y" | sudo docker volume prune

echo  "Creating new containers for PHP Apache and MySQL..."
sudo docker run -dit --name $containerForApacheServer  -p 8080:80 --network $networkName -v "$PWD/$originalFolderWebsite":/var/www/html php:8.0-apache
sudo docker run --name $containerForMySQL -p 3306:3306 --network $networkName -e MYSQL_ROOT_PASSWORD=$mySQLPassword -d mysql:8.0

echo "Installing Mysqli in PHP Apache Server..."
sudo docker exec -it $containerForApacheServer docker-php-ext-install mysqli
sudo docker exec -it $containerForApacheServer docker-php-ext-enable mysqli
sudo docker restart $containerForApacheServer

echo "Testing MySQL connection:"

wget http://localhost:8080/index.php

echo "Checking lines with mysql database names:"

cat index.php | grep "MiguelCintron"

echo "Installation complete!"

echo "You can enter to the website in http://localhost:8080/index.php and look for MySQL initial databases names in the initial slider to check MySQL Connection"