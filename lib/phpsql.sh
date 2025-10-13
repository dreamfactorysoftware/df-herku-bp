#!/bin/bash
set -e

arrow() { echo "----->" "$@"; }

BUILD_DIR=$1
BP_DIR=$2
ext_dir=$(php-config --extension-dir)

arrow "PHP extension dir: $ext_dir"

# Grab sqlsrv/pdo_sqlsrv prebuilt binaries matching PHP 8.3 (NTS)
# 5.12.0 supports PHP 8.3; adjust if you pin a newer msphpsql release.
SQLSRV_VER=8.3
MSPHPSQL_VER=5.12.0
DRIVER_URL="https://github.com/microsoft/msphpsql/releases/download/v${MSPHPSQL_VER}/Linux_${MSPHPSQL_VER}RTW.tar.gz"

arrow "Downloading msphpsql ${MSPHPSQL_VER} (PHP ${SQLSRV_VER})"
wget -q "$DRIVER_URL" -O /tmp/msphpsql.tar.gz
mkdir -p /tmp/msphpsql
tar -xzf /tmp/msphpsql.tar.gz -C /tmp/msphpsql

# Filenames are lowercase with hyphens, e.g. sqlsrv-8.3.so / pdo_sqlsrv-8.3.so
sqlsrv_so=$(find /tmp/msphpsql -type f -name "sqlsrv-${SQLSRV_VER}.so" -print -quit)
pdo_so=$(find /tmp/msphpsql -type f -name "pdo_sqlsrv-${SQLSRV_VER}.so" -print -quit)

if [[ -z "$sqlsrv_so" || -z "$pdo_so" ]]; then
  echo "Error: sqlsrv/pdo_sqlsrv ${SQLSRV_VER} .so files not found" >&2
  exit 1
fi

cp "$sqlsrv_so" "$ext_dir/sqlsrv.so"
cp "$pdo_so" "$ext_dir/pdo_sqlsrv.so"

mkdir -p "$BUILD_DIR/.heroku/php/etc/php/conf.d"
echo "extension=sqlsrv.so" > "$BUILD_DIR/.heroku/php/etc/php/conf.d/sqlsrv.ini"
echo "extension=pdo_sqlsrv.so" > "$BUILD_DIR/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini"

arrow "sqlsrv/pdo_sqlsrv installed for PHP ${SQLSRV_VER}"

# Cleanup
rm -rf /tmp/msphpsql /tmp/msphpsql.tar.gz
