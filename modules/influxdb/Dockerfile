# start with standard public influx image
FROM influxdb:1.8.2

# copy in our database initialization script
# creates telemetry database and sets retention policy
COPY initdb.iql /docker-entrypoint-initdb.d/init.iql

# copy in our config
COPY influxdb.conf /etc/influxdb/influxdb.conf

# launch influx daemon
# TODO:  probably don't need this
CMD ["influxd"]
