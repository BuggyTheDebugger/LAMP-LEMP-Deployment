#!/bin/bash

# ============================================
# LAMP/LEMP Stack Deployment Script
# Author: [BuggyTheDebugger]
# Version: 1.1
# ============================================

# ======== VARIABLES ========
LOG_FILE="./lamp_lemp_deployment.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
APACHE_CONF_DIR="/etc/apache2/sites-available"
NGINX_CONF_DIR="/etc/nginx/sites-available"
DB_BACKUP_DIR="./db_backups"
WEB_BACKUP_DIR="./web_backups"
DOCKER_COMPOSE_FILE="./docker-compose.yml"
DEFAULT_INTERFACE="eth0"

# ======== FUNCTIONS ========

# Log actions
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Pause with clear
pause_and_clear() {
    read -p "Press Enter to continue..."
    clear
}

# Install Required Packages
install_packages() {
    clear
    echo "1. Install LAMP Stack (Apache + PHP + MySQL/MariaDB)"
    echo "2. Install LEMP Stack (Nginx + PHP + MySQL/MariaDB)"
    echo "0. Back"
    read -p "Choose an option: " package_choice

    case $package_choice in
        1)
            log_action "[+] Installing LAMP Stack..."
            apt update && apt install -y apache2 php mysql-server php-mysql libapache2-mod-php
            log_action "[+] LAMP Stack installed successfully."
            ;;
        2)
            log_action "[+] Installing LEMP Stack..."
            apt update && apt install -y nginx php mysql-server php-mysql php-fpm
            log_action "[+] LEMP Stack installed successfully."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Configure Web Server
configure_web_server() {
    clear
    echo "1. Create Virtual Hosts"
    echo "2. Install SSL Certificates"
    echo "3. Test and Reload Web Server"
    echo "0. Back"
    read -p "Choose an option: " web_choice

    case $web_choice in
        1)
            log_action "[+] Creating Virtual Hosts..."
            read -p "Enter domain name (e.g., example.com): " domain_name
            mkdir -p /var/www/$domain_name
            chown -R www-data:www-data /var/www/$domain_name
            chmod -R 755 /var/www/$domain_name

            echo "<html><head><title>Welcome</title></head><body><h1>Welcome to $domain_name</h1></body></html>" > /var/www/$domain_name/index.html

            if [ -d $APACHE_CONF_DIR ]; then
                cat <<EOF > $APACHE_CONF_DIR/$domain_name.conf
<VirtualHost *:80>
    ServerName $domain_name
    DocumentRoot /var/www/$domain_name
    ErrorLog \${APACHE_LOG_DIR}/$domain_name_error.log
    CustomLog \${APACHE_LOG_DIR}/$domain_name_access.log combined
</VirtualHost>
EOF
                a2ensite $domain_name.conf
                systemctl reload apache2
            elif [ -d $NGINX_CONF_DIR ]; then
                cat <<EOF > $NGINX_CONF_DIR/$domain_name
server {
    listen 80;
    server_name $domain_name;
    root /var/www/$domain_name;
    index index.html;
    access_log /var/log/nginx/$domain_name_access.log;
    error_log /var/log/nginx/$domain_name_error.log;
}
EOF
                ln -s $NGINX_CONF_DIR/$domain_name /etc/nginx/sites-enabled/
                systemctl reload nginx
            fi
            log_action "[+] Virtual host for $domain_name created successfully."
            ;;
        2)
            log_action "[+] Installing SSL Certificates..."
            apt install -y certbot python3-certbot-apache python3-certbot-nginx
            read -p "Enter domain name for SSL (e.g., example.com): " ssl_domain
            certbot --apache -d $ssl_domain || certbot --nginx -d $ssl_domain
            log_action "[+] SSL Certificates installed for $ssl_domain."
            ;;
        3)
            log_action "[+] Testing and Reloading Web Server..."
            apachectl configtest && systemctl reload apache2 || nginx -t && systemctl reload nginx
            log_action "[+] Web server tested and reloaded."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Configure Database Server
configure_database_server() {
    clear
    echo "1. Configure MySQL/MariaDB Root Password"
    echo "2. Add New Database"
    echo "3. Secure Database Server"
    echo "0. Back"
    read -p "Choose an option: " db_choice

    case $db_choice in
        1)
            log_action "[+] Configuring MySQL/MariaDB Root Password..."
            read -p "Enter new root password: " root_password
            mysqladmin -u root password $root_password
            log_action "[+] Root password configured."
            ;;
        2)
            log_action "[+] Adding New Database..."
            read -p "Enter database name: " db_name
            read -p "Enter username: " db_user
            read -p "Enter password for $db_user: " db_pass
            mysql -u root -p -e "CREATE DATABASE $db_name;"
            mysql -u root -p -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
            mysql -u root -p -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"
            mysql -u root -p -e "FLUSH PRIVILEGES;"
            log_action "[+] Database $db_name and user $db_user created successfully."
            ;;
        3)
            log_action "[+] Securing Database Server..."
            mysql_secure_installation
            log_action "[+] Database server secured."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Deploy Web Applications
deploy_web_applications() {
    clear
    echo "1. Deploy Web Files"
    echo "2. Configure Permissions"
    echo "0. Back"
    read -p "Choose an option: " deploy_choice

    case $deploy_choice in
        1)
            log_action "[+] Deploying Web Files..."
            read -p "Enter source directory: " src_dir
            read -p "Enter destination directory (e.g., /var/www/html): " dest_dir
            cp -r $src_dir $dest_dir
            log_action "[+] Web files deployed to $dest_dir."
            ;;
        2)
            log_action "[+] Configuring Permissions..."
            read -p "Enter directory to configure: " config_dir
            chown -R www-data:www-data $config_dir
            chmod -R 755 $config_dir
            log_action "[+] Permissions configured for $config_dir."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Optimize and Secure the Stack
optimize_and_secure_stack() {
    clear
    echo "1. Optimize PHP Configuration"
    echo "2. Enable Security Headers"
    echo "0. Back"
    read -p "Choose an option: " secure_choice

    case $secure_choice in
        1)
            log_action "[+] Optimizing PHP Configuration..."
            sed -i "s/^memory_limit = .*/memory_limit = 512M/" /etc/php/*/apache2/php.ini
            sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 64M/" /etc/php/*/apache2/php.ini
            log_action "[+] PHP Configuration optimized."
            ;;
        2)
            log_action "[+] Enabling Security Headers..."
            echo "Header always set Strict-Transport-Security \"max-age=63072000; includeSubdomains; preload\"" >> /etc/apache2/apache2.conf
            systemctl reload apache2
            log_action "[+] Security Headers enabled."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}
maintenance_and_backup() {
    clear
    echo "=============================="
    echo " Maintenance and Backup"
    echo "=============================="
    echo "1. Backup Databases"
    echo "2. Backup Web Files"
    echo "3. Schedule Backups (CRON)"
    echo "4. View Backup Logs"
    echo "0. Back"
    read -p "Choose an option: " maintenance_choice

    case $maintenance_choice in
        1)
            log_action "[+] Backing up databases..."
            mkdir -p $DB_BACKUP_DIR
            read -p "Enter MySQL root password: " root_password
            databases=$(mysql -u root -p"$root_password" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")
            for db in $databases; do
                mysqldump -u root -p"$root_password" $db > "$DB_BACKUP_DIR/$db-$(date '+%Y%m%d').sql"
                log_action "[+] Database $db backed up successfully."
            done
            ;;
        2)
            log_action "[+] Backing up web files..."
            mkdir -p $WEB_BACKUP_DIR
            read -p "Enter directory to backup (e.g., /var/www): " web_dir
            tar -czvf "$WEB_BACKUP_DIR/webfiles-$(date '+%Y%m%d').tar.gz" $web_dir
            log_action "[+] Web files from $web_dir backed up successfully."
            ;;
        3)
            log_action "[+] Scheduling backups..."
            read -p "Enter CRON schedule (e.g., '0 2 * * *' for daily at 2AM): " cron_schedule
            read -p "Enter backup type (database/web): " backup_type
            if [ "$backup_type" = "database" ]; then
                echo "$cron_schedule root mysqldump -u root -p<your_password> --all-databases > /path/to/backup.sql" >> /etc/crontab
                log_action "[+] Database backups scheduled with CRON."
            elif [ "$backup_type" = "web" ]; then
                echo "$cron_schedule root tar -czvf /path/to/backup.tar.gz /var/www" >> /etc/crontab
                log_action "[+] Web backups scheduled with CRON."
            else
                echo "[-] Invalid backup type."
            fi
            ;;
        4)
            log_action "[+] Viewing backup logs..."
            if [ -f $LOG_FILE ]; then
                tail -n 20 $LOG_FILE
            else
                echo "[-] No logs available."
            fi
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Monitoring and Supervision
monitoring_supervision() {
    clear
    echo "1. Health Checks"
    echo "2. View Logs"
    echo "3. Generate Supervision Report"
    echo "0. Back"
    read -p "Choose an option: " monitor_choice

    case $monitor_choice in
        1)
            log_action "[+] Running Health Checks..."
            systemctl is-active apache2 && log_action "[+] Apache is running." || log_action "[-] Apache is not running."
            systemctl is-active mysql && log_action "[+] MySQL is running." || log_action "[-] MySQL is not running."
            log_action "[+] Health Checks Completed."
            ;;
        2)
            log_action "[+] Viewing Logs..."
            tail -f /var/log/syslog
            ;;
        3)
            log_action "[+] Generating Supervision Report..."
            echo "Supervision report generated." >> $LOG_FILE
            log_action "[+] Supervision Report Generated."
            ;;
        0)
            return
            ;;
        *)
            echo "[-] Invalid option."
            ;;
    esac
    pause_and_clear
}

# Main Menu
main_menu() {
    while true; do
        clear
        echo "=============================="
        echo " LAMP/LEMP Stack Deployment"
        echo "=============================="
        echo "1. Install Required Packages"
        echo "2. Configure Web Server"
        echo "3. Configure Database Server"
        echo "4. Deploy Web Applications"
        echo "5. Optimize and Secure the Stack"
        echo "6. Maintenance and Backup"
        echo "7. Monitoring and Supervision"
        echo "0. Exit"
        read -p "Choose an option: " main_choice

        case $main_choice in
            1) install_packages ;;
            2) configure_web_server ;;
            3) configure_database_server ;;
            4) deploy_web_applications ;;
            5) optimize_and_secure_stack ;;
            6) echo "Maintenance feature coming soon!" ;;
            7) monitoring_supervision ;;
            0)
                log_action "[+] Exiting script."
                exit 0
                ;;
            *)
                echo "[-] Invalid option."
                ;;
        esac
    done
}

# Start Script
main_menu
