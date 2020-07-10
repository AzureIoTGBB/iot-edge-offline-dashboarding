# Customize the IoT Offline Dashboarding sample for other use cases

The process for customizing or re-using the sample for other use cases will, obviously, depend on the details of the use case. However, some high level guidance can be found below.

> [!NOTE]
> This page describes the adaptation of the sample for other, non-manufacturing industries or use cases. If you are interested in just adding your own data sources to the sample, please see [Customizing the offline dashboarding solution](customize-sample-oee.md).

**Table of contents**
* [Understanding the current code and architecture](#understanding-the-current-code-and-architecture)
* [Data sources](#data-sources)
* [Moving data from edgeHub to InfluxDB](#moving-data-from-edgeHub-to-InfluxDB)
* [Understanding InfluxDB](#understanding-influxdb)
* [Understanding Grafana](#understanding-grafana)

## Understanding the current code and architecture

One key to customization of the solution is gaining a good understanding of how it works. Reading all the documentation is good, but like most samples "the truth is in the code".

[Deploying the solution](deployment-manual.md) "as-is" is a great starting point for understanding its functionality. The deployment process will create a Grafana dashboards to look at, however it's important to understand the Node-RED flows for both the `opcsimulator` and more importantly, the `edgetoinfluxdb` module flow.

Using the same `'az cli vm open-port'` command as during the enviroment prep will also open port 1880 (opcsimulator) and port 1881 (edgetoinfluxdb).

This will enable `http://{vm ip address}:1880` and `http://{vm ip address}:1881` to see those flows.

> [!NOTE]
> Since this is a sample, those flows are not secured with any kind of authentication. Only do this on a box with test data!

## Data sources

The first step in customization will be shutting off the sample data sources. Remove the opcsimulator and opcpublisher module from the solution by removing them from the [deployment.template.json](/deployment.template.json) file, and if desired, deleting the corresponding folders in /modules.

After that, add your own data source(s). This can be done by using an IoT "leaf" device (i.e. a device external to IoT Edge) and "push" the data to IoT Edge (see [Connect a downstream device to an Azure IoT Edge gateway](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-connect-downstream-device)). Alternatively by writing a module to "pull" the data from its source (like a [Modbus protocol gateway](https://docs.microsoft.com/en-us/azure/iot-edge/deploy-modbus-gateway) or OPC Publisher).

The key requirement is that whichever source is used, it needs to submit the data to edgeHub through an [edgeHub route](https://docs.microsoft.com/en-us/azure/iot-edge/module-composition#declare-routes) to route the data into the 'edgetoinfluxdb' module.

## Moving data from edgeHub to InfluxDB

The `edgetoinfluxdb` module, which is implemented as Node-Red flow, subscribes to messages from the edgeHub, reformats them as an InfluxDB 'upsert' command, and submits them to the `influxdb` module. This is done in the `Build JSON` node in the flow.

To use new flows in the sample, export each of them and overwrite the `flows.json` file. 

If there are additional Node-RED add-ins required, add those to the `npm install` commands in the Dockerfile.

Here is a JSON message produced by the sample by default:

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

Here are a few tips creating JSON messages:

* Use a JSON array as a root that may contain multiple tuples
* `"measurement"` refers to the table name to insert data into different measurement buckets.
* `"fields"` are actual metrics / telemetry / data points that are identified by timestamp and tag values
* Use multiple field values in a single message
* Alternatively, use separate messages for different fields. As long as the timestamp and tag values are the same, these are considered to be part of same tuple.
* `"tags"` are values that describe the metric, for example to identify or locate the asset. Use this flow to further contextualize the data by accessing other LOB systems and merging data into same tuple as a tag.
* Use the `iothub-enqueuedtime` [system property](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-construct#system-properties-of-d2c-iot-hub-messages) of the message from edgeHub as the message `timestamp` or create a separate value, according to your use case. Please note that `timestamp` is a Unix Epoch timestamp and, in the case above, has a precision of nanoseconds.

## Understanding InfluxDB

The InfluxDB module should be usable 'as-is'. One small change to consider is data retention time. For the sample the InfluxDB only retains data for one day. If the data needs to be retained longer, modify the `initdb.iql` file and rebuild / redeploy the container.

When adding any additional datasources beyond InfluxDB, add them to the [datasource.yaml](/modules/grafana/grafana-provisioning/datasources/datasource.yml) file.

## Understanding Grafana

A tutorial on developing Grafana dashboards is beyond the scope of this documentation, however the [Grafana documentation](https://grafana.com/docs/grafana/latest/) is a good place to start. A web search also provides lots of tutorials and examples.

Note that our sample dashboards and InfluxDB use the `flux` plug-in and query language, which is great for working with time series data.

When developing new dashboard(s), put them in the [dashboards](/modules/grafana/grafana-provisioning) folder. The built-in Grafana provisioning process will pick up all artifacts from there, as well as any additional data sources from the [datasource.yaml](/modules/grafana/grafana-provisioning/datasources/datasource.yml) file.

Rebuild and redeploy all the containers after any change via your chosen deployment method.
