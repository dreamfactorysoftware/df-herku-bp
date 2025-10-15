#!/bin/bash
set -e

arrow() { echo "----->" "$@"; }

BUILD_DIR=$1
BP_DIR=$2
ext_dir=$(php-config --extension-dir)

arrow "PHP extension dir: $ext_dir"

SQLSRV_VER=8.3
MSPHPSQL_VER=5.12.0
TMP=/tmp/msphpsql
rm -rf "$TMP" && mkdir -p "$TMP"

DRIVER_URL="https://github.com/microsoft/msphpsql/releases/download/v${MSPHPSQL_VER}/Linux_${MSPHPSQL_VER}RTW.tar.gz"
arrow "Downloading msphpsql ${MSPHPSQL_VER} (PHP ${SQLSRV_VER})"
curl -fsSL "$DRIVER_URL" -o "$TMP/pkg.tgz"

tar -xzf "$TMP/pkg.tgz" -C "$TMP"

arrow "Searching for NTS binaries inside archive"
sqlsrv_so=$(find "$TMP" -type f -name "SQLSRV_${SQLSRV_VER}_NTS.so" | head -n1 || true)
pdo_so=$(find "$TMP" -type f -name "PDO_SQLSRV_${SQLSRV_VER}_NTS.so" | head -n1 || true)

# Fallbacks for other layouts Microsoft sometimes ships
if [[ -z "$sqlsrv_so" || -z "$pdo_so" ]]; then
  sqlsrv_so=${sqlsrv_so:-$(find "$TMP" -type f -name "sqlsrv-${SQLSRV_VER}.so" | head -n1 || true)}
  pdo_so=${pdo_so:-$(find "$TMP" -type f -name "pdo_sqlsrv-${SQLSRV_VER}.so" | head -n1 || true)}
fi
if [[ -z "$sqlsrv_so" || -z "$pdo_so" ]]; then
  sqlsrv_so=${sqlsrv_so:-$(find "$TMP" -type f -path "*/php-${SQLSRV_VER}/nts/sqlsrv.so" | head -n1 || true)}
  pdo_so=${pdo_so:-$(find "$TMP" -type f -path "*/php-${SQLSRV_VER}/nts/pdo_sqlsrv.so" | head -n1 || true)}
fi

echo "       sqlsrv candidate: ${sqlsrv_so}"
echo "       pdo_sqlsrv candidate: ${pdo_so}"

if [[ -z "$sqlsrv_so" || -z "$pdo_so" ]]; then
  echo "Error: could not locate sqlsrv/pdo_sqlsrv NTS binaries for PHP ${SQLSRV_VER}." >&2
  find "$TMP" -type f -maxdepth 3 -name "*.so" | sed 's/^/       /'
  exit 1
fi

cp "$sqlsrv_so" "$ext_dir/sqlsrv.so"
cp "$pdo_so"   "$ext_dir/pdo_sqlsrv.so"

mkdir -p "$BUILD_DIR/.heroku/php/etc/php/conf.d"
echo "extension=sqlsrv.so"     > "$BUILD_DIR/.heroku/php/etc/php/conf.d/sqlsrv.ini"
echo "extension=pdo_sqlsrv.so" > "$BUILD_DIR/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini"

arrow "Installed sqlsrv/pdo_sqlsrv (NTS) for PHP ${SQLSRV_VER}"

# cleanup
rm -rf "$TMP"
