#!/bin/bash

PSQLPASS=vagrantpostgres

#
# trytond.conf
#

read -r -d '' CONF << EOM
[database]
uri = postgresql://trytond:$PSQLPASS@localhost
path = /usr/local/bin/trytond

[web]
listen = *:8000

[session]
# Default password is adminsuper
super_pwd = iCi2M7sA20NKk
EOM

#
# trytond_log.conf
#

read -r -d '' LOG << EOM
[formatters]
keys: simple

[handlers]
keys: rotate, console

[loggers]
keys: root

[formatter_simple]
format: %(asctime)s] %(levelname)s:%(name)s:%(message)s
datefmt: %a %b %d %H:%M:%S %Y

[handler_rotate]
class: handlers.TimedRotatingFileHandler
args: ('/var/log/trytond/trytond.log', 'D', 1, 7)
formatter: simple

[handler_console]
class: StreamHandler
formatter: simple
args: (sys.stdout,)

[logger_root]
level: INFO
handlers: rotate, console
EOM

#
# trytond.service
#

read -r -d '' SERV << EOM
[Unit]
Description=Tryton server
After=syslog.target

[Service]
Type=simple
User=trytond
Group=trytond
PIDFile=/var/run/trytond/trytond.pid
ExecStart=/usr/local/bin/trytond --config /usr/local/etc/trytond.conf --pidfile /var/run/trytond/trytond.pid --logconf /usr/local/etc/trytond_log.conf
TimeoutSec=300
Restart=always

[Install]
WantedBy=multi-user.target
EOM

#
# Ubuntu packages
#

PACKAGES="python python-dev python-pip libxml2-dev\
   libxslt1-dev postgresql postgresql-server-dev-9.5"
echo "PACKAGES: " $PACKAGES

#
# Commands
#


date > /etc/vagrant_provisioned_at
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y $PACKAGES
pip install --upgrade pip
pip install psycopg2
pip install trytond

useradd -r trytond
su postgres -c "createuser -d trytond"
su postgres -c "psql -c \"ALTER USER trytond WITH PASSWORD '$PSQLPASS';\""
mkdir /var/run/trytond
chown trytond.trytond /var/run/trytond
mkdir /var/log/trytond
chown trytond.trytond /var/log/trytond

echo "$CONF" > /usr/local/etc/trytond.conf
echo "$LOG" > /usr/local/etc/trytond_log.conf
chown trytond.trytond /usr/local/etc/*

echo "$SERV" > /etc/systemd/system/trytond.service
systemctl start trytond.service
systemctl enable trytond

