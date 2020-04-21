curl "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE telemetry"
curl "http://localhost:8086/query" --data-urlencode "q=CREATE RETENTION POLICY rp1day ON telemetry DURATION 1d REPLICATION 1 DEFAULT"

