#!/bin/bash
set -e

PG_VERSION="16"
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"
REPL_USER="replicator"
REPL_PASS="CHANGE_ME"
REPL_NET="192.168.40.0/24"
DB_NAME="CHANGE_ME"

echo "[1/7] Instalando PostgreSQL ${PG_VERSION}..."
apt update
apt install -y postgresql-${PG_VERSION}

echo "[2/7] Configurando postgresql.conf..."
sed -i "s/^#\?listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"

grep -q "^wal_level" "$PG_CONF" \
  && sed -i "s/^wal_level.*/wal_level = replica/" "$PG_CONF" \
  || echo "wal_level = replica" >> "$PG_CONF"

grep -q "^max_wal_senders" "$PG_CONF" \
  && sed -i "s/^max_wal_senders.*/max_wal_senders = 5/" "$PG_CONF" \
  || echo "max_wal_senders = 5" >> "$PG_CONF"

grep -q "^wal_keep_size" "$PG_CONF" \
  && sed -i "s/^wal_keep_size.*/wal_keep_size = 64/" "$PG_CONF" \
  || echo "wal_keep_size = 64" >> "$PG_CONF"

grep -q "^hot_standby" "$PG_CONF" \
  && sed -i "s/^hot_standby.*/hot_standby = on/" "$PG_CONF" \
  || echo "hot_standby = on" >> "$PG_CONF"

echo "[3/7] Configurando pg_hba.conf..."
grep -q "host replication ${REPL_USER} ${REPL_NET} md5" "$PG_HBA" \
  || echo "host replication ${REPL_USER} ${REPL_NET} md5" >> "$PG_HBA"

echo "[4/7] Reiniciando PostgreSQL..."
systemctl restart postgresql
systemctl enable postgresql

echo "[5/7] Creando usuario de replicación..."
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${REPL_USER}'" | grep -q 1 \
  || sudo -u postgres psql -c "CREATE ROLE ${REPL_USER} WITH REPLICATION LOGIN PASSWORD '${REPL_PASS}';"

echo "[6/7] Creando base de datos ${DB_NAME}..."
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1 \
  || sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};"

echo "[7/7] Creando vista info_node..."
sudo -u postgres psql -d "${DB_NAME}" <<'SQL'
CREATE OR REPLACE VIEW info_node AS
SELECT
    CASE
        WHEN inet_server_addr() = '192.168.30.2'::inet THEN 'srv-db-01'
        WHEN inet_server_addr() = '192.168.30.3'::inet THEN 'srv-db-02'
        ELSE 'desconegut'
    END AS nom_node,
    inet_server_addr()::text AS ip_node,
    CASE
        WHEN pg_is_in_recovery() THEN 'Replica'
        ELSE 'Primary'
    END AS rol_node,
    now() AS data_actual;
SQL

echo
echo "Configuración PRIMARY completada."
echo "Comprueba con:"
echo "  systemctl status postgresql"
echo "  sudo -u postgres psql -d ${DB_NAME} -c 'SELECT * FROM info_node;'"
