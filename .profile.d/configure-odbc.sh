#!/bin/bash
set -e

# Paths where the apt buildpack installed things
export PATH="$HOME/.apt/opt/mssql-tools/bin:$PATH"

# msodbcsql18 installs into this lib64 directory. Add it so PHP can find libmsodbcsql-18*.so
export LD_LIBRARY_PATH="$HOME/.apt/opt/microsoft/msodbcsql18/lib64:${LD_LIBRARY_PATH}"

# unixODBC driver/DSN config locations within .apt
export ODBCSYSINI="$HOME/.apt/etc"
export ODBCINI="$HOME/.apt/etc/odbc.ini"

# Ensure driver registration file exists and points at the right .so
mkdir -p "$HOME/.apt/etc"

cat > "$HOME/.apt/etc/odbcinst.ini" <<'INI'
[ODBC Driver 18 for SQL Server]
Description=Microsoft ODBC Driver 18 for SQL Server
Driver=/app/.apt/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.4.so.1.1
UsageCount=1
INI
