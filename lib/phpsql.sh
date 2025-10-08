#!/bin/bash
set -e

# Get extension directory
ext_directory=$(php-config --extension-dir)
echo "Extension Directory: $ext_directory"

# Download sqlsrv extensions
sqlsrv_drivers='https://github.com/microsoft/msphpsql/releases/download/v5.12.0/Linux_5.12.0RTW.tar.gz'
wget -q "$sqlsrv_drivers" -O sqlsrv.tar.gz

# Determine top-level directory inside the archive and extract
top_dir=$(tar -tzf sqlsrv.tar.gz | head -1 | cut -d/ -f1)
 
# Extract
tar -xzf sqlsrv.tar.gz

# Move extensions (adjust the version number to match your PHP version)
mv "${top_dir}/SQLSRV_8.3_NTS.so" "$ext_directory/sqlsrv.so"
mv "${top_dir}/PDO_SQLSRV_8.3_NTS.so" "$ext_directory/pdo_sqlsrv.so"

# Enable extensions
echo "extension=sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini

# Cleanup
rm -rf "$top_dir" sqlsrv.tar.gz

echo "✓ sqlsrv extensions installed"
php -m | grep sqlsrv