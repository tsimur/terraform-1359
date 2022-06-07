#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo apt-get update
sudo apt-get -y install php
cat <<\EOT >> /tmp/index.php
<?php
$localIP = getHostByName(getHostName());
echo "<h1>Local IP is:</h1>";
echo "<h1 style='color:red; font-size: 100px;'>".$localIP."</h1>";
?>
EOT
sudo cp /tmp/index.php /var/www/html
sudo rm /var/www/html/index.html