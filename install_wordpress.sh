#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# WordPress configuration
# db_name="afadb"
# db_user="afauser"
# db_password="afapwd"
# db_host="localhost"

# Main installation function
install_wordpress() {
    # Navigate to target directory
    echo -e "${YELLOW}Navigating to /var/www/html...${NC}"
    cd /var/www/html || { 
        echo -e "${RED}✘ Failed to navigate to /var/www/html${NC}"
        exit 1
    }

    # Download latest WordPress
    echo -e "${YELLOW}Downloading latest WordPress...${NC}"
    sudo wget https://wordpress.org/latest.tar.gz

    # Check if download was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ WordPress downloaded successfully!${NC}"
    else
        echo -e "${RED}✘ Failed to download WordPress${NC}"
        exit 1
    fi

    # Extract WordPress
    echo -e "${YELLOW}Extracting WordPress...${NC}"
    sudo tar -zxvf latest.tar.gz

    # Rename wp-config-sample.php to be wp-config.php
    sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    
    # Configure WordPress wp-config.php
    echo -e "${YELLOW}Configuring WordPress database settings...${NC}"
    sudo sed -i "s/define( 'DB_NAME', '.*' );/define( 'DB_NAME', '$db_name' );/" /var/www/html/wordpress/wp-config.php
    sudo sed -i "s/define( 'DB_USER', '.*' );/define( 'DB_USER', '$db_user' );/" /var/www/html/wordpress/wp-config.php
    sudo sed -i "s/define( 'DB_PASSWORD', '.*' );/define( 'DB_PASSWORD', '$db_password' );/" /var/www/html/wordpress/wp-config.php
    sudo sed -i "s/define( 'DB_HOST', '.*' );/define( 'DB_HOST', '$db_host' );/" /var/www/html/wordpress/wp-config.php

    # Verify configuration changes
    echo -e "${YELLOW}Verifying WordPress configuration...${NC}"
    if grep -q "define( 'DB_NAME', '$db_name' );" /var/www/html/wordpress/wp-config.php &&
       grep -q "define( 'DB_USER', '$db_user' );" /var/www/html/wordpress/wp-config.php &&
       grep -q "define( 'DB_PASSWORD', '$db_password' );" /var/www/html/wordpress/wp-config.php &&
       grep -q "define( 'DB_HOST', '$db_host' );" /var/www/html/wordpress/wp-config.php; then
        echo -e "${GREEN}✔ WordPress configuration updated successfully!${NC}"
    else
        echo -e "${RED}✘ Failed to update WordPress configuration${NC}"
        exit 1
    fi

    # Set proper permissions
    echo -e "${YELLOW}Setting WordPress directory permissions...${NC}"
    sudo chown -R www-data:www-data /var/www/html/wordpress
    sudo chmod -R 755 /var/www/html/wordpress

    # Verify permissions
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ WordPress permissions set successfully!${NC}"
    else
        echo -e "${RED}✘ Failed to set WordPress permissions${NC}"
        exit 1
    fi

    # Clean up tar.gz file
    echo -e "${YELLOW}Cleaning up downloaded archive...${NC}"
    sudo rm latest.tar.gz

    echo -e "${GREEN}✔ WordPress installation completed successfully!${NC}"
}

# Run the main function
main() {
    # Check if script is run with sudo
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}✘ This script must be run with sudo${NC}"
        exit 1
    fi

    # Run WordPress installation
    install_wordpress
}

# Execute main function
main
