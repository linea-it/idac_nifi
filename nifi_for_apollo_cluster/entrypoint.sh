#!/bin/bash
set -e

echo "Configurando MUNGE..."

mkdir -p /run/munge 
mkdir -p /var/log/munge 
mkdir -p /var/lib/munge

chown -R munge:munge /run/munge || true
chown -R munge:munge /var/log/munge || true
chown -R munge:munge /var/lib/munge || true
chown -R munge:munge /etc/munge || true

chmod 755 /run/munge
chmod 700 /etc/munge
chmod 700 /var/lib/munge
chmod 700 /var/log/munge

if [ -f /etc/munge/munge.key ]; then
    chmod 400 /etc/munge/munge.key
fi

echo "Subindo munged..."
pgrep munged >/dev/null || \
runuser -u munge -- /usr/sbin/munged

echo "Iniciando NiFi..."
exec /opt/nifi/scripts/start.sh
