#!/bin/bash

# This script sets up a WordPress-ready Apache server with security and performance best practices
# Compatible with Ubuntu/Debian and CentOS/RHEL-based systems

set -e

echo "Detecting OS..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS"
    exit 1
fi

# Update package list and system packages
echo "Updating package lists..."
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo apt update && sudo apt upgrade -y
    INSTALL="sudo apt install -y"
    APACHE="apache2"
    PHP_PACKAGES="php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip php-opcache"
    MYSQL="mysql-server"
    CERTBOT="certbot python3-certbot-apache"
    FIREWALL="ufw"
    FAIL2BAN="fail2ban"
    UNATTENDED="unattended-upgrades"
    LOGWATCH="logwatch"
elif [[ "$OS" == "centos" || "$OS" == "rocky" || "$OS" == "almalinux" ]]; then
    sudo yum update -y
    INSTALL="sudo yum install -y"
    APACHE="httpd"
    PHP_PACKAGES="php php-mysqlnd php-cli php-curl php-gd php-mbstring php-xml php-zip php-opcache"
    MYSQL="mariadb-server"
    CERTBOT="certbot python3-certbot-apache"
    FIREWALL="firewalld"
    FAIL2BAN="fail2ban"
    UNATTENDED=""
    LOGWATCH="logwatch"
else
    echo "Unsupported OS"
    exit 1
fi

# Install required packages
echo "Installing Apache, PHP, MySQL, Certbot, Fail2Ban, Logwatch..."
$INSTALL $APACHE $PHP_PACKAGES $MYSQL $CERTBOT $FAIL2BAN $LOGWATCH

# Enable and start Apache and MySQL
echo "Enabling and starting Apache and MySQL..."
sudo systemctl enable $APACHE
sudo systemctl start $APACHE
sudo systemctl enable mysqld
sudo systemctl start mysqld

# Enable Apache modules
echo "Enabling Apache modules..."
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo a2enmod rewrite headers ssl
fi

# Disable directory listing for security
echo "Securing Apache - disabling directory listing..."
echo "<Directory /var/www/html>
    Options -Indexes
    AllowOverride All
</Directory>" | sudo tee /etc/apache2/conf-available/hardening.conf > /dev/null

if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo a2enconf hardening
    sudo systemctl reload apache2
fi

# Setup firewall rules
echo "Setting up firewall rules..."
if [[ "$FIREWALL" == "ufw" ]]; then
    sudo ufw allow OpenSSH
    sudo ufw allow 'Apache Full'
    sudo ufw --force enable
elif [[ "$FIREWALL" == "firewalld" ]]; then
    sudo systemctl start firewalld
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-service=ssh
    sudo firewall-cmd --reload
fi

# Configure Fail2Ban to start on boot
echo "Configuring Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Download and install WordPress into the default web directory
echo "Installing WordPress..."
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo rsync -av wordpress/ /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Optional: set up automatic security updates
echo "Setting up automatic security updates (if supported)..."
if [[ ! -z "$UNATTENDED" ]]; then
    $INSTALL $UNATTENDED
    sudo dpkg-reconfigure -plow unattended-upgrades
fi

# Summary and manual follow-up
echo "Setup complete. Don't forget to:"
echo "- Run 'mysql_secure_installation' to harden your database"
echo "- Create a MySQL database and user for WordPress"
echo "- Set up your domain name and run: sudo certbot --apache"
echo "- Edit wp-config.php with your DB credentials"

echo "✅ All done!"
