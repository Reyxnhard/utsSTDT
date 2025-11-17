#!/bin/bash
set -e

# Only run on first initialization (docker-entrypoint-initdb.d)
echo "Init primary: configure replication user and settings"

# Create replication user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'replpw';
EOSQL

# Enable settings by appending to postgresql.conf (if not present)
cat >> /var/lib/postgresql/data/postgresql.auto.conf <<-EOF
# replication settings
listen_addresses = '*'
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
archive_mode = off
hot_standby = on
EOF

# Allow replication connections from replica container (pg_hba.conf provided)
echo "Primary init finished"
