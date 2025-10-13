#!/bin/bash
set -e

# -----------------------------
# Set library path for ODBC drivers
# -----------------------------
export LD_LIBRARY_PATH="$HOME/.apt/usr/lib:$LD_LIBRARY_PATH"

# -----------------------------
# Detect MS ODBC version and driver .so
# -----------------------------
for f in $HOME/.apt/opt/microsoft/*; do
    MS_ODBC_VERSION=$(basename "$f" | grep -oE '[0-9]+')
    break
done

for f in $HOME/.apt/usr/lib/libmsodbcsql*.so*; do
    MS_ODBC_DRIVER_FILE=$(basename "$f")
    break
done

# -----------------------------
# Create ODBC config files
# -----------------------------
export ODBCINI="$HOME/.apt/usr/lib/odbc/conf/odbc.ini"
export ODBCSYSINI="$HOME/.apt/usr/lib/odbc/conf/odbcinst.ini"

mkdir -p "$HOME/.apt/usr/lib/odbc/conf"

cat <<EOF > $ODBCINI
[ODBC Driver ${MS_ODBC_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MS_ODBC_VERSION} for SQL Server
Driver=$HOME/.apt/usr/lib/$MS_ODBC_DRIVER_FILE
UsageCount=1
EOF

cat <<EOF > $ODBCSYSINI
[ODBC Driver ${MS_ODBC_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MS_ODBC_VERSION} for SQL Server
Driver=$HOME/.apt/usr/lib/$MS_ODBC_DRIVER_FILE
EOF

echo "✅ ODBC configuration ready"
