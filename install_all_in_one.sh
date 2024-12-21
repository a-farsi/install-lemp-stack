#!/bin/bash

# Source the properties file
PROPERTIES_FILE="app.properties"
if [ -f "$PROPERTIES_FILE" ]; then
    # Read the properties file
    while IFS='=' read -r key value; do
        # Ignore lines starting with '#' (comments) and empty lines
        if [[ ! "$key" =~ ^# && -n "$key" ]]; then
            # Export the variables to make them available
            export "$key"="$value"
        fi
    done < "$PROPERTIES_FILE"
else
    echo "Error: Properties file '$PROPERTIES_FILE' not found."
    exit 1
fi

# Call each script using the variables from the properties file
echo "Start Installing Nginx..."
./install_nginx.sh "$url"

echo "Start Installing MariaDB..."
./install_mariadb.sh

echo "Start Installing PHP..."
./install_php.sh "$version_php"

echo "Start Installing WordPress..."
./install_wordpress.sh

echo "All components installed successfully!"

