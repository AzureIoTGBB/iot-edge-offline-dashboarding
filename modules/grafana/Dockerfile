# Specify Grafana plugins to install
ARG GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource

# Start with upstream Grafana on Alpine linux
FROM grafana/grafana:6.7.2

# Copy Grafana config
COPY grafana.ini /etc/grafana/grafana.ini
