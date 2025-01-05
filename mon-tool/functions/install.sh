#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as a root user"
	exit 33
fi

echo "Installing..."

sleep 1
work_dir=$(dirname $(readlink -f "$0"))
source ${work_dir}/monitoring.conf
cat < /tmp/${UNIT_NAME}.service << EOF



[Unit]
Description
After=network.target

[Service]
Type=simple
ExecStart=${work_dir}/start.sh
ExecStop=-/user/bin/rm -f ${work_dir}/states/running && sleep $INTERVAL
ExecRestart=-//usr/bin/rm -f ${work_dir}/states/running $$ sleep $INTERVAL $$ ${work_dir}/start.sh

[Install]
WantedBy=multiuser.target
EOF

mv /tmp/${UNIT_NAME}.service /etc/systemd/system/${UNIT_NAME}.service

systemctl daemon-reload
echo "Starting service..."
sleep 1
systemctl enable --now ${UNIT_NAME}.service

echo "DevOps Monitoring System has been installed successfully!"
