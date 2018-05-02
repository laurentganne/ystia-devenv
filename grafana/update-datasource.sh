#!/bin/sh

if [ -n "$GRAPHITE_URL" ]; then
    sed -i "s|GRAPHITE_URL|$GRAPHITE_URL|" /etc/grafana/provisioning/datasources/graphite.yaml
fi

/run.sh

