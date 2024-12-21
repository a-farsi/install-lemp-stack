#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

version_php="$1"

# PHP configuration file path
PHP_INI_PATH="/etc/php/${version_php}/fpm/php.ini"

# Function to install PHP
install_php() {

    # Ensure the parameter is provided
    if [[ -z ${version_php} ]]; then
        echo -e "${RED}Error: PHP version_php is required as parameter.${NC}"
        echo "Usage: ./install-php.sh v"
        exit 1
    fi
    
    # Check if PHP ${version_php} is installed
    if php -v | grep -q "PHP ${v}"; then
        echo "PHP ${version_php} is already installed."
    else
        echo "PHP ${version_php} is not installed. Installing now..."
        
        # Update package lists
        sudo apt update

        # Install PHP ${version_php} and required extensions
        sudo apt install php${version_php} php${version_php}-fpm php${version_php}-curl php${version_php}-mysql php${version_php}-gd php${version_php}-mbstring php${version_php}-xml php${version_php}-imagick php${version_php}-zip php${version_php}-xmlrpc -y
        
        # Verify installation
        if php -v | grep -q "PHP ${version_php}"; then
            echo "PHP ${version_php} installed successfully."
        else
            echo "Failed to install PHP ${version_php}."
        fi
    fi
}

# Function to modify PHP configuration
modify_php_config() {
    # Array of configurations to modify
    declare -A configs=(
        ["cgi.fix_pathinfo"]="0"
        ["upload_max_filesize"]="128M"
        ["post_max_size"]="128M"
        ["memory_limit"]="512M"
        ["max_execution_time"]="120"
    )

    echo -e "${YELLOW}Modifying PHP configuration file: $PHP_INI_PATH${NC}"

    # Iterate through configurations
    for config_key in "${!configs[@]}"; do
        config_value="${configs[$config_key]}"

        # Special handling for cgi.fix_pathinfo to remove semicolon and set value
        if [ "$config_key" == "cgi.fix_pathinfo" ]; then
            # Precisely remove semicolon while preserving white spaces and set value to 0
            sudo sed -i "s/^;cgi\.fix_pathinfo\s*=\s*[0-9]/cgi.fix_pathinfo = $config_value/" "$PHP_INI_PATH"
            
            echo -e "${GREEN}✔ Uncommented and set $config_key = $config_value${NC}"
        else
            # For other parameters, replace or add if not exists
            if sudo grep -q "^$config_key =" "$PHP_INI_PATH"; then
                # Replace existing configuration
                sudo sed -i "s/^$config_key\s*=.*/$config_key = $config_value/" "$PHP_INI_PATH"
                echo -e "${GREEN}✔ Updated $config_key to $config_value${NC}"
            else
                # Add configuration if not exists
                echo "$config_key = $config_value" | sudo tee -a "$PHP_INI_PATH" > /dev/null
                echo -e "${YELLOW}➕ Added $config_key = $config_value${NC}"
            fi
        fi
    done

    # Verify changes
    echo -e "${YELLOW}Verifying configuration changes...${NC}"
    for config_key in "${!configs[@]}"; do
        config_value="${configs[$config_key]}"
        current_value=$(grep "^$config_key =" "$PHP_INI_PATH" | cut -d '=' -f2 | xargs)
        
        if [ "$current_value" == "$config_value" ]; then
            echo -e "${GREEN}✔ $config_key is set to $config_value${NC}"
        else
            echo -e "${RED}✘ Failed to set $config_key${NC}"
            return 1
        fi
    done

    return 0
}

# Restart PHP-FPM service to apply changes
restart_php_fpm() {
    echo -e "${YELLOW}Restarting PHP-FPM service...${NC}"
    sudo systemctl restart php${version_php}-fpm

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ PHP-FPM service restarted successfully!${NC}"
        return 0
    else
        echo -e "${RED}✘ Failed to restart PHP-FPM service${NC}"
        return 1
    fi
}

# Main script
main() {
    # Install PHP
    install_php

    # Modify PHP configuration
    if modify_php_config; then
        # Restart PHP-FPM to apply changes
        if restart_php_fpm; then
            echo -e "${GREEN}✔ PHP configuration updated and service restarted successfully!${NC}"
            exit 0
        else
            echo -e "${RED}✘ Failed to restart PHP-FPM service${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✘ Failed to modify PHP configuration${NC}"
        exit 1
    fi
}

# Run the main function
main "$@"
