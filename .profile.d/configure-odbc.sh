#!/bin/bash
set -e

# Detect ODBC version
for f in ${HOME}/.apt/opt/microsoft/*; do
    MS_ODBC_VERSION=$(echo "$(basename "$f")" | grep -o -E '[0-9]+')
    break
done

# Detect ODBC driver file (the .so file)
for f in ${HOME}/.apt/usr/lib/*msodbcsql*.so; do
    MS_ODBC_DRIVER_FILE=$(basename "$f")
    break
done

# Ensure directories exist
export ODBCINI=${HOME}/.apt/usr/lib/odbc/conf
export ODBCSYSINI=${HOME}/.apt/usr/lib/odbc/conf
mkdir -p "$ODBCINI"

# Create ODBC config files
cat <<EOF > ${ODBCINI}/odbc.ini
[ODBC Driver ${MS_ODBC_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MS_ODBC_VERSION} for SQL Server
Driver=/app/.apt/usr/lib/${MS_ODBC_DRIVER_FILE}
UsageCount=1
EOF

cat <<EOF > ${ODBCSYSINI}/odbcinst.ini
[ODBC Driver ${MS_ODBC_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MS_ODBC_VERSION} for SQL Server
Driver=/app/.apt/usr/lib/${MS_ODBC_DRIVER_FILE}
EOF

echo "ODBC configuration generated:"
cat ${ODBCINI}/odbc.ini
