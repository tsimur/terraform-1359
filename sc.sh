#!/bin/bash
sudo apt-get -y update
# sudo apt-get -y install nginx
# sudo systemctl restart nginx
# sudo systemctl enable nginx
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