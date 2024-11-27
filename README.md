
# LAMP/LEMP Stack Deployment Script

## Overview

This is a comprehensive Bash script designed to automate the deployment, configuration, and maintenance of LAMP or LEMP stacks. It provides an interactive menu system for setting up web servers, database servers, and related features with minimal effort.

## Features

- **LAMP/LEMP Stack Installation**:
  - Apache, Nginx, PHP, MySQL/MariaDB installation.

- **Web Server Configuration**:
  - Create virtual hosts for Apache or Nginx.
  - Install SSL certificates using Certbot.
  - Test and reload configurations.

- **Database Server Management**:
  - Set root passwords.
  - Create new databases and users.
  - Secure MySQL/MariaDB.

- **Web Application Deployment**:
  - Deploy web files with permission configuration.

- **Optimization and Security**:
  - Optimize PHP settings.
  - Enable HTTP security headers.

- **Maintenance and Backup**:
  - Backup databases and web files.
  - Schedule automatic backups using CRON.

- **Monitoring and Supervision**:
  - Health checks for services.
  - Generate supervision reports.

## Requirements

- **Operating System**: Linux-based distributions (e.g., Ubuntu, Debian).
- **Privileges**: Root or sudo access.
- **Packages**:
  - `apache2`, `nginx`, `mysql-server`, `php`, `certbot`.
  - Additional utilities such as `tar`, `gzip`, `cron`.

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/BuggyTheDebugger/LAMP-LEMP-Deployment.git
   cd LAMP-LEMP-Deployment
   ```

2. Make the script executable:
   ```bash
   chmod +x lamp_lemp_deployment.sh
   ```

3. Run the script:
   ```bash
   sudo ./lamp_lemp_deployment.sh
   ```

4. Follow the interactive menu to perform desired actions.

## Example

- **Install LAMP Stack**:
  Select option `1` from the main menu and choose "Install LAMP Stack".

- **Create a Virtual Host**:
  Navigate to `Configure Web Server > Create Virtual Hosts` and follow the prompts.

## Contribution

Contributions are welcome! If you have suggestions or improvements, feel free to fork this repository, make your changes, and submit a pull request.


---

**Author**: BuggyTheDebugger
