#!/bin/bash
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
sudo su
apt-get update -y
apt-get install httpd -y
systemctl start httpd
systemctl enable httpd
echo 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' >> /var/www/html/index.html
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd