# Customize the dashboard sample for other use cases

The process for customizing or re-using the sample for other use cases will, obviously, depend on the details of the use case.  However, some high level guidance can be found below.

## Data sources

The first step will be shutting off the sample data sources. To do this, you should remove the opcsimulator and opcpublisher module from the solution. This can be done by removing them from the [deployment.template.json](/deployment.template.json) file, and if desired, deleting the corresponding folder from the sample.

You'll then need to add your own data source.  This can be done by having an IoT "leaf" device (i.e. a device external to IoT Edge) "push" the data to IoT Edge (See [Connect a downstream device to an Azure IoT Edge gateway](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-connect-downstream-device)), or by writing a module to "pull" the data from its source (like [Modbus protocol gateway](https://docs.microsoft.com/en-us/azure/iot-edge/deploy-modbus-gateway) or OPC Publisher).  The key requirement is that whichever source you use needs to submit the data to edgeHub, and you need to set up an edgeHub [route](https://docs.microsoft.com/en-us/azure/iot-edge/module-composition#declare-routes) to route the data into the 'edgetoinfluxdb' module.

## Moving data from edgeHub to InfluxDB

The 'edgetoinfluxdb' module, which is implemented as Node-Red flow, subscribest to messages from the edgeHub, reformats them as an influxdb 'upsert' command, and submits them to the 'influxdb' module.  This is done in the "Build JSON" node in the flow. You can look at the existing one in the sample for an idea of how it is done.

There is an example JSON messages produced by the sample

```json
[
  {
    "measurement": "DeviceData",
    "fields": {
      "ITEM_COUNT_BAD": 8,
      "ITEM_COUNT_GOOD": 1
    },
    "tags": {
      "Source": "urn:edgevm3.internal.cloudapp.net:OPC-Site-02"
    },
    "timestamp": 1591382648856000000
  }
]
```

Here are a few tips for creating the JSON message for InfluxDB

- It is a JSON array which may contain multiple tuples
- "measurement" is similar to table name, you may insert data into different measurements.
- "fields" are actual metrics/data points that are identified by time stamp and tag values
- You may use multiple field values in a single message. You may also use separate messages for different fields. As long as, timestamp and tag values are the same, these are considered to be part of same tuple.
- "tags" are values that describe the metric. Such as which asset it is or where it is located. You can use this flow to further contextualize your data by accessing other LOB systems and merging data into same tuple as a tag.
- You can use the 'iothub-enqueuedtime' [system property](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-construct#system-properties-of-d2c-iot-hub-messages) of the message from edgeHub as your timestamp or create your own value here, according to your solution requirements.  Please note that timestamp is a Unix Epoch timestamp and, in the case above, has a precision of nanoseconds.

To use your new flows in the sample, you need to export them and overwrite the 'flows.json' file.  

If you require any additional Node-RED add-ins, you need to add those to the npm install commands in the Dockerfile as well

## InfluxDB module

You should be able to use the InfluxDB module 'as-is'. One small change you can consider is data retention time. For the sample, we set InfluxDB to only retain data for one day. If you desire to retain your data longer, you can modify the initdb.iql file and rebuild/redeploy your container

## Grafana

A tutorial on developing Grafana dashboards is beyond our scope here, however a the grafana documentation is a good place to start, as well as a web search provides lots of tutorials and examples. Not to mention our own sample dashboards provide great examples. Happy Hunting.

Note that our sample dashboards and Influx use the 'flux' plug-in and query language, which is great for working with time series data.

Once you do develop your new dashboard(s), you should put them in the [dashboards](/modules/grafana/grafana-provisioning) folder. If you added any additional datasources beyond InfluxDB, you can add that to the [datasource.yaml](/modules/grafana/grafana-provisioning/datasources/datasource.yml) file. The built-in Grafana provisioning process will pick up all those artifacts from there.

Once this is all is done, just rebuild and redeploy all the containers via your chosen deployment method.  Then test, debug, test, debug, rinse and repeat!
