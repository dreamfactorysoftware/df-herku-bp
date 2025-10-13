#!/bin/bash
set -e

arrow() { echo "----->" "$@"; }
indent() { sed -u 's/^/       /'; }

BUILD_DIR=$1      # e.g., /app
BP_DIR=$2         # buildpack directory
ext_dir=$(php-config --extension-dir)

arrow "PHP extension dir: $ext_dir"

# -----------------------------
# Step 1: Download SQLSRV extensions
# -----------------------------
SQLSRV_VER=8.3
DRIVER_URL='https://github.com/microsoft/msphpsql/releases/download/v5.12.0/Linux_5.12.0RTW.tar.gz'

arrow "Downloading SQLSRV/PDO_SQLSRV $SQLSRV_VER"
wget -q "$DRIVER_URL" -O sqlsrv.tar.gz

mkdir -p LINUX_SQLSRV
tar -xzf sqlsrv.tar.gz -C LINUX_SQLSRV

sqlsrv_so=$(find LINUX_SQLSRV -type f -name "SQLSRV_${SQLSRV_VER}_NTS.so" -print -quit)
pdo_so=$(find LINUX_SQLSRV -type f -name "PDO_SQLSRV_${SQLSRV_VER}_NTS.so" -print -quit)

if [[ -z "$sqlsrv_so" || -z "$pdo_so" ]]; then
  echo "Error: SQLSRV/PDO_SQLSRV binaries not found!" >&2
  exit 1
fi

cp "$sqlsrv_so" "$ext_dir/sqlsrv.so"
cp "$pdo_so" "$ext_dir/pdo_sqlsrv.so"

echo "extension=sqlsrv.so" > "$BUILD_DIR/.heroku/php/etc/php/conf.d/sqlsrv.ini"
echo "extension=pdo_sqlsrv.so" > "$BUILD_DIR/.heroku/php/etc/php/conf.d/pdo_sqlsrv.ini"

arrow "SQLSRV extensions installed"

# -----------------------------
# Step 2: Copy Microsoft ODBC Driver
# -----------------------------
# Detect MS ODBC version
for f in $BUILD_DIR/.apt/opt/microsoft/*; do
    MS_ODBC_VERSION=$(basename "$f" | grep -oE '[0-9]+')
    break
done

arrow "Adding Microsoft ODBC Driver $MS_ODBC_VERSION"

mkdir -p "$BUILD_DIR/.apt/usr/lib"
mkdir -p "$BUILD_DIR/.apt/usr/lib/odbc/conf"
mkdir -p "$BUILD_DIR/.apt/usr/share/resources/en_US"

# Copy Microsoft ODBC libraries
cp -L $BUILD_DIR/.apt/opt/microsoft/msodbcsql${MS_ODBC_VERSION}/lib64/*.so* $BUILD_DIR/.apt/usr/lib/ | indent
# Copy unixODBC libraries
cp -L $BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu/libodbc*.so* $BUILD_DIR/.apt/usr/lib/ | indent

# Create symlinks for MS ODBC
cd $BUILD_DIR/.apt/usr/lib
ln -sf libmsodbcsql-${MS_ODBC_VERSION}.so.1.1 libmsodbcsql-${MS_ODBC_VERSION}.so

# Copy language resources
cp -a $BUILD_DIR/.apt/opt/microsoft/msodbcsql${MS_ODBC_VERSION}/share/resources/en_US/. $BUILD_DIR/.apt/usr/share/resources/en_US/ | indent

# -----------------------------
# Step 3: Copy profile.d script
# -----------------------------
mkdir -p "$BUILD_DIR/.profile.d"
cp "$BP_DIR/.profile.d/configure-odbc.sh" "$BUILD_DIR/.profile.d" | indent

arrow "Microsoft ODBC Driver $MS_ODBC_VERSION installed"

# -----------------------------
# Step 4: Cleanup
# -----------------------------
rm -f sqlsrv.tar.gz
rm -rf LINUX_SQLSRV

arrow "SQLSRV setup complete"
