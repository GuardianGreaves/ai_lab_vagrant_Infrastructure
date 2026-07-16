#!/bin/bash

set -e


echo "=== Load variables ==="

source /vagrant/variables.sh


echo "=== Updating system ==="

apt update
apt upgrade -y



echo "=== Installing PostgreSQL ==="

apt install -y postgresql postgresql-contrib



echo "=== Starting PostgreSQL ==="

systemctl enable postgresql
systemctl start postgresql



PG_VERSION=$(ls /etc/postgresql | head -n 1)



echo "=== Configure PostgreSQL ==="


# Разрешаем подключения не только localhost

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" \
/etc/postgresql/$PG_VERSION/main/postgresql.conf



echo "=== Configure pg_hba.conf ==="


cat >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf <<EOF

# Vagrant network
host    all    all    192.168.56.0/24    scram-sha-256

EOF



echo "=== Creating users and databases ==="



sudo -u postgres psql <<EOF

-- n8n

CREATE USER $N8N_USER WITH PASSWORD '$N8N_PASSWORD';

CREATE DATABASE $N8N_DB
OWNER $N8N_USER;



-- AI memory

CREATE USER $AGENT_USER WITH PASSWORD '$AGENT_PASSWORD';

CREATE DATABASE $AGENT_DB
OWNER $AGENT_USER;



-- Wiki.js

CREATE USER $WIKI_USER WITH PASSWORD '$WIKI_PASSWORD';

CREATE DATABASE $WIKI_DB
OWNER $WIKI_USER;



GRANT ALL PRIVILEGES ON DATABASE $N8N_DB TO $N8N_USER;

GRANT ALL PRIVILEGES ON DATABASE $AGENT_DB TO $AGENT_USER;

GRANT ALL PRIVILEGES ON DATABASE $WIKI_DB TO $WIKI_USER;


EOF



echo "=== Restart PostgreSQL ==="

systemctl restart postgresql



echo "=== Check PostgreSQL ==="


systemctl status postgresql --no-pager



echo "=== Database list ==="


sudo -u postgres psql -c "\l"



echo "=== PostgreSQL ready ==="