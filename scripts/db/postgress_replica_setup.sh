#!/bin/bash
set -e

PG_VERSION="16"
PG_DATA="/var/lib/postgresql/${PG_VERSION}/main"
PRIMARY_REPL_IP="192.168.40.1"
REPL_USER="replicator"
REPL_PASS="Change_ME"

echo "[1/6] Instalando PostgreSQL ${PG_VERSION}..."
apt update
apt install -y postgresql-${PG_VERSION}

echo "[2/6] Parando PostgreSQL..."
systemctl stop postgresql

echo "[3/6] Limpiando directorio de datos..."
rm -rf "${PG_DATA:?}"/*

echo "[4/6] Lanzando pg_basebackup desde el primario..."
export PGPASSWORD="${REPL_PASS}"
sudo -u postgres pg_basebackup \
  -h "${PRIMARY_REPL_IP}" \
  -D "${PG_DATA}" \
  -U "${REPL_USER}" \
  -P -R

echo "[5/6] Ajustando permisos..."
chown -R postgres:postgres "${PG_DATA}"
chmod 700 "${PG_DATA}"

echo "[6/6] Arrancando PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

echo
echo "Configuración REPLICA completada."
echo "Comprueba con:"
echo "  systemctl status postgresql"
echo "  sudo -u postgres psql -c 'SELECT pg_is_in_recovery();'"
