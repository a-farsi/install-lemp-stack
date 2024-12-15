#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check Nginx page with HTTP status
check_nginx_page() {
    # Ensure the parameter is provided
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: URL parameter is required.${NC}"
        echo "Usage: ./install-nginx-script.sh <URL>"
        exit 1
    fi
    local url="$1"

    # Use curl with -I (head) to get only headers
    local http_response=$(curl -sI "$url")

    # Extract the HTTP status code (first line, third word)
    local status_code=$(echo "$http_response" | head -n 1 | awk '{print $2}')

    # Check if the status code is 200
    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}✔ Nginx is successfully installed and accessible!${NC}"
        echo -e "${YELLOW}HTTP Response Headers:${NC}"
        echo "$http_response"
        return 0
    else
        echo -e "${RED}✘ Nginx page check failed. HTTP Status Code: $status_code${NC}"
        echo -e "${YELLOW}Full Response Headers:${NC}"
        echo "$http_response"
        return 1
    fi
}

# Function to check if Nginx is running
check_nginx_status() {

    # Run systemctl start
    sudo systemctl start nginx

    # Run systemctl status and grep for the specific status line
    if sudo systemctl status nginx | grep -q "Active: active (running)"; then
        echo -e "${GREEN}✔ Nginx service is running successfully!${NC}"
        return 0
    else
        echo -e "${RED}✘ Nginx is not running or has an issue.${NC}"
        return 1
    fi
}

copy_wordpress_config() {
    local wordpress_conf_template="wordpress.conf"
    local nginx_conf_path="/etc/nginx/conf.d/wordpress.conf"

    if [[ -f "$wordpress_conf_template" ]]; then
        echo -e "${YELLOW}Configuring Nginx for WordPress...${NC}"
        sed "s|<url>|$url|g" "$wordpress_conf_template" | sudo tee "$nginx_conf_path" > /dev/null
        echo -e "${GREEN}✔ Nginx configuration for WordPress updated at $nginx_conf_path.${NC}"
    else
        echo -e "${RED}✘ Template file $wordpress_conf_template not found.${NC}"
        exit 1
    fi
}

# Main script
main() {
    # Ensure the script received a URL as an argument
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: URL parameter is required.${NC}"
        echo "Usage: ./install-nginx-script.sh <URL>"
        exit 1
    fi

    local url="$1"

    # Update package lists
    echo -e "${YELLOW}Updating package lists...${NC}"
    sudo apt update

    # Upgrade existing packages (optional, but recommended)
    echo -e "${YELLOW}Upgrading existing packages...${NC}"
    sudo apt upgrade -y

    # Install Nginx with automatic yes to prompts
    echo -e "${YELLOW}Installing Nginx...${NC}"
    sudo apt install nginx -y

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ Nginx installation completed.${NC}"

        # Wait a moment to ensure service has time to start
        sleep 2

        # Copy the wordpress configuration file 
        copy_wordpress_config "$url"

        # Check Nginx service status
        if check_nginx_status; then
            # Check Nginx page
            if check_nginx_page "$url"; then
                echo -e "${GREEN}✔ Nginx installation and verification successful!${NC}"
                exit 0
            else
                echo -e "${RED}✘ Nginx page check failed.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}✘ Failed to start Nginx service.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✘ Nginx installation failed.${NC}"
        exit 1
    fi
}

# Run the main function
main "$@"
