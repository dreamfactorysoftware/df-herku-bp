#!/bin/bash
set -e

# Get extension directory
ext_directory=$(php-config --extension-dir)
echo "Extension Directory: $ext_directory"

# Download sqlsrv extensions
sqlsrv_drivers='https://github.com/microsoft/msphpsql/releases/download/v5.12.0/Linux_5.12.0RTW.tar.gz'
wget -q "$sqlsrv_drivers" -O sqlsrv.tar.gz

# Extract entire archive into a named folder
mkdir -p LINUX_SQLSRV
tar -xzf sqlsrv.tar.gz -C LINUX_SQLSRV

# Move exact 8.3 NTS binaries from the named folder
sqlsrv_path=$(find LINUX_SQLSRV -type f -name 'SQLSRV_8.3_NTS.so' -print -quit)
pdosrv_path=$(find LINUX_SQLSRV -type f -name 'PDO_SQLSRV_8.3_NTS.so' -print -quit)

if [ -z "$sqlsrv_path" ] || [ -z "$pdosrv_path" ]; then
  echo "Error: Required SQLSRV/PDO_SQLSRV 8.3 NTS binaries not found after extraction." >&2
  rm -f sqlsrv.tar.gz
  rm -rf LINUX_SQLSRV
  exit 1
fi

cp "$sqlsrv_path" "$ext_directory/sqlsrv.so"
cp "$pdosrv_path" "$ext_directory/pdo_sqlsrv.so"

# Enable extensions
echo "extension=sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /app/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini

# Cleanup
rm -f sqlsrv.tar.gz 2>/dev/null || true
rm -rf LINUX_SQLSRV 2>/dev/null || true

echo "✓ sqlsrv extensions installed"
php -m | grep sqlsrv