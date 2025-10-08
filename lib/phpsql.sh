#!/bin/bash
set -e  # Exit on error

# Get extension directory
ext_directory=$(php-config --extension-dir)

echo "Extension Directory: $ext_directory"

# Download sqlsrv extensions
sqlsrv_drivers='https://github.com/microsoft/msphpsql/releases/download/v5.12.0/Linux_5.12.0RTW.tar.gz'
wget -q $sqlsrv_drivers -O sqlsrv.tar.gz

# Extract
tar -xzf sqlsrv.tar.gz

# Move extensions (adjust the version number to match your PHP version)
mv "Linux_5.12.0RTW/SQLSRV_8.3_NTS.so" "$ext_directory/sqlsrv.so"
mv "Linux_5.12.0RTW/PDO_SQLSRV_8.3_NTS.so" "$ext_directory/pdo_sqlsrv.so"

# Enable extensions
echo "extension=sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini

# Cleanup
rm -rf Linux_5.12.0RTW sqlsrv.tar.gz

echo "✓ sqlsrv extensions installed"
php -m | grep sqlsrv