# 🔐 WordPress Apache Server Hardening Script

This script automates the setup of a secure, performance-optimized WordPress environment on a fresh or existing Linux server. It detects the OS (Ubuntu/Debian or CentOS/RHEL-based), installs Apache, PHP, MySQL/MariaDB, and WordPress, and applies essential best practices for security, reliability, and performance.

---

## ⚙️ What It Does

- ✅ Installs or updates:
  - Apache (if missing)
  - PHP with common modules
  - MySQL or MariaDB
  - WordPress core files
- 🔒 Configures server hardening:
  - UFW or Firewalld rules (SSH, HTTP, HTTPS)
  - Fail2Ban protection (SSH login brute-force)
  - Directory listing disabled
  - `mod_rewrite` and HTTPS enabled
- 🚀 Enables performance optimizations:
  - PHP OPcache
  - Apache caching modules
- 🧪 Adds maintenance tools:
  - Logwatch for system activity summaries
  - Unattended security updates (if supported)

---

## 🖥️ Supported Environments

- Ubuntu 20.04+ / Debian 10+
- CentOS 7/8 / AlmaLinux / Rocky Linux
- Apache web server
- Requires `sudo` privileges

---

## 🚀 Getting Started

### Step 1: Upload the script to your server:
scp setup-wordpress-server.sh youruser@yourserver:/tmp

### Step 2: Upload the script to your server:
ssh youruser@yourserver
cd /tmp
chmod +x setup-wordpress-server.sh
sudo ./setup-wordpress-server.sh

---

## 📝 Post-Setup Checklist

### Step 1. After the script runs successfully, secure your MySQL installation:
sudo mysql_secure_installation

### Step 2. Create a WordPress database and user:
CREATE DATABASE wp_db;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;

### Step 3. Update wp-config.php with your DB credentials.

### Step 4. Set up your domain name and SSL certificate:
sudo certbot --apache

---

## 📁 File Structure

/var/www/html
- index.php
- wp-admin/
- wp-content/
- wp-includes/

---

## 📌 Notes

- This script does not overwrite existing WordPress content, but you should back up your site before running it on a live server.
- Fail2Ban includes only basic SSH protection by default. You can extend it to WordPress login URLs with a custom jail/filter.
- Docker and cloud backups are not included in this version but can be added later.

---

## 📄 License

This project is open source under the [MIT License](LICENSE).

---

## ✉️ Credits

Created by RichGerg - built as an automated bash script to automate the setup of a secure, optimized WordPress environment on Linux using Apache, PHP, and MySQL.
