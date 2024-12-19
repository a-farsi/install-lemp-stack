#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check and install MariaDB
install_mariadb() {
    echo -e "${YELLOW}Installing MariaDB server and client...${NC}"
    sudo apt-get update
    sudo apt-get install -y mariadb-server mariadb-client

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ MariaDB installed successfully!${NC}"
    else
        echo -e "${RED}✘ MariaDB installation failed.${NC}"
        exit 1
    fi
}

# Function to ensure MariaDB is running
ensure_mariadb_running() {
    echo -e "${YELLOW}Checking MariaDB service status...${NC}"
    if ! sudo systemctl status mariadb | grep -q "Active: active (running)"; then
        echo -e "${RED}MariaDB is not running. Starting MariaDB...${NC}"
        sudo systemctl start mariadb
    fi

    if sudo systemctl status mariadb | grep -q "Active: active (running)"; then
        echo -e "${GREEN}✔ MariaDB service is running!${NC}"
    else
        echo -e "${RED}✘ Failed to start MariaDB service.${NC}"
        exit 1
    fi
}

# Function to secure MariaDB installation in silent mode
secure_mariadb_silent() {
    echo -e "${YELLOW}Securing MariaDB installation...${NC}"

    # Define root password
    local root_password="your_new_password"

    # Run SQL commands to secure MariaDB
    sudo mariadb -u root -pyour_new_password<<EOF
-- For MariaDB 10.4+ (recommended syntax)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Disallow root login remotely
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Reload privilege tables
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ MariaDB secured successfully!${NC}"
    else
        echo -e "${RED}✘ Failed to secure MariaDB.${NC}"
        exit 1
    fi
}

# Function to create a database and user
setup_database() {
    local db_name="afadb"
    local db_user="afauser"
    local db_password="afapwd"

    echo -e "${YELLOW}Creating database '${db_name}' and user '${db_user}' with specified privileges...${NC}"

    # Run SQL commands in MariaDB
    sudo mariadb -u root -p"your_new_password"<<EOF
CREATE DATABASE IF NOT EXISTS ${db_name};
CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
GRANT SELECT, INSERT, UPDATE, CREATE, INDEX, ALTER, CREATE ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ Database '${db_name}', user '${db_user}', and privileges setup completed successfully!${NC}"
    else
        echo -e "${RED}✘ Failed to set up database and user.${NC}"
        exit 1
    fi
}

# Main script execution
main() {
    install_mariadb
    ensure_mariadb_running
    secure_mariadb_silent
    setup_database
    echo -e "${GREEN}✔ MariaDB installation and configuration completed successfully!${NC}"
}

# Execute main function
main
