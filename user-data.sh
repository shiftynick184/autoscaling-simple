#!/bin/bash
sudo su
apt-get update -y
apt-get install httpd -y
systemctl start httpd
systemctl enable httpd
echo 'Hire Me :)' >> /var/www/html/index.html
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd