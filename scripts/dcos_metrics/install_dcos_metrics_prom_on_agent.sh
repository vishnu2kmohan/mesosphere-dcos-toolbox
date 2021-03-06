#!/bin/bash

# This file:
#
#  - Deploys dcos-metrics-prometheus-plugin on to an agent node
#  NOTE this will overwrite your dcos-metrics.env 
#
# Usage:
#
#  ./install_dcos_metrics_prom_on_master.sh
#  OR
#  curl --retry 3 -fsSL https://raw.githubusercontent.com/elubow/mesosphere-dcos-toolbox/master/scripts/dcos_metrics/install_dcos_metrics_prom_on_agent.sh
#
# Version:
#   0.1 - 1-Mar-18 - [Eric Lubow] - Initial version

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
#set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

PLUGIN_VERSION="1.10.5"
PLUGIN_URL="https://github.com/dcos/dcos-metrics/releases/download/${PLUGIN_VERSION}/dcos-metrics-prometheus-plugin_${PLUGIN_VERSION}"

echo "downloading plugin"
# STEP sudo curl -L https://github.com/dcos/dcos-metrics/releases/download/1.10.4/dcos-metrics-prometheus-plugin_1.10.4 -o /opt/mesosphere/bin/dcos-metrics-prometheus-plugin
# STEP chmod 0755 /opt/mesosphere/bin/dcos-metrics-prometheus-plugin
sudo curl -L ${PLUGIN_URL} -o /opt/mesosphere/bin/dcos-metrics-prometheus-plugin
chmod 0755 /opt/mesosphere/bin/dcos-metrics-prometheus-plugin

echo "writing environment files"
# STEP sudo echo "PROMETHEUS_PORT=8088" > /opt/mesosphere/etc/dcos-metrics-prometheus.env
tee /opt/mesosphere/etc/dcos-metrics-prometheus.env <<EOF
PROMETHEUS_PORT=9273
EOF

# STEP sudo echo "DCOS_METRICS_CONFIG_PATH=/opt/mesosphere/etc" > /opt/mesosphere/etc/dcos-metrics.env
tee /opt/mesosphere/etc/dcos-metrics.env <<EOF
DCOS_METRICS_CONFIG_PATH=/opt/mesosphere/etc
EOF


tee /etc/systemd/system/dcos-metrics-prometheus-agent.service <<EOF
[Unit]
Description=DC/OS Metrics Agent Prometheus Plugin
[Service]
Restart=always
RestartSec=60
PermissionsStartOnly=True
User=dcos_metrics
SupplementaryGroups=dcos_adminrouter
EnvironmentFile=/opt/mesosphere/environment
EnvironmentFile=/opt/mesosphere/etc/dcos-metrics.env
EnvironmentFile=/opt/mesosphere/etc/dcos-metrics-prometheus.env
ExecStart=/opt/mesosphere/bin/dcos-metrics-prometheus-plugin --dcos-role agent
EOF

echo "starting daemons"
# STEP sudo systemctl daemon-reload
sudo systemctl daemon-reload
# STEP sudo systemctl start dcos-metrics-prometheus-agent
sudo systemctl start dcos-metrics-prometheus-agent

#echo "showing logs"
sudo systemctl status dcos-metrics-prometheus-agent -l
#journalctl -u dcos-metrics-prometheus-plugin
