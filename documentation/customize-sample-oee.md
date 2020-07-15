
# Customizing the IoT Offline Dashboarding sample

The components in the solution are driven by configuration files, contained in and deployed via their corresponding Docker images. This allows customizing the dashboard, by simply updating the corresponding dashboard configuration file and redeploying (possibly 'at scale') the respective images.

> [!NOTE]
> This page describes customization within the defined manufacturing scenario. If you are interested in adapting the sample for other industries or use cases, please see [Customizing the dashboard sample for other use cases](customize-sample-other.md).

**Table of contents**
* [Connecting assets / OPC servers](#connecting-assets-/-opc-servers)
* [Adding a new asset (basic scenario)](#adding-a-new-asset-basic-scenario)
* [Adding a new asset (complex scenario)](#adding-a-new-asset-complex-scenario)

## Connecting assets / OPC servers

### Removing simulators

To remove the simulators, modify the `publishedNodes.json` file found in `modules\opcpublisher` and remove the two nodes shown below. Their data will stop flowing into the database.

```json
 [
     {
      "EndpointUrl": "opc.tcp://opcsimulator:54845/OPCUA/Site1",
       "UseSecurity": false,
       "OpcNodes": [
        {
          "Id": "ns=1;s=STATUS",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "STATUS"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_GOOD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_GOOD"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_BAD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_BAD"
        }
      ]
    },
    {
      "EndpointUrl": "opc.tcp://opcsimulator:54855/OPCUA/Site2",
      "UseSecurity": false,
      "OpcNodes": [
        {
          "Id": "ns=1;s=STATUS",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "STATUS"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_GOOD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_GOOD"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_BAD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_BAD"
        }
      ]
    }
 ]
```

Afterwards, delete the previously added telemetry records from InfluxDB:

```sql
DROP MEASUREMENT DeviceData
```

Note that edge-to-flux flow automatically creates measurements if it does not exists.

Finally, remove the "opcsimulator" module from deployment.

### Adding a new asset (basic scenario)

The following steps assume an OPC Server, installed and connected to real assets and equipment, that publishes three data points (`STATUS`, `ITEM_COUNT_GOOD`, `ITEM_COUNT_BAD`).

#### Configuring the OPC UA server

Configure the OPC UA server to publish the following data points with numeric data types:

1. STATUS (double)
1. ITEM_COUNT_GOOD (double)
1. ITEM_COUNT_BAD (double)

Note down the "NodeId" values for all three data points, which are used in the `publishedNodes.json` configuration file.

Configure the security aspects to make sure the solution has access.

#### Adding nodes to the solution

The `publishedNodes.json` configuration file contains the OPC UA nodes to be monitored by the OPC Publisher module. The file can be found in `modules\opcpublisher`. By default the configuration contains two simulators (see above) and three nodes for each simulator:

```json
  [
     {
      "EndpointUrl": "opc.tcp://opcsimulator:54845/OPCUA/Site1",
       "UseSecurity": false,
       "OpcNodes": [
        {
          "Id": "ns=1;s=STATUS",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "STATUS"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_GOOD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_GOOD"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_BAD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_BAD"
        }
      ]
    },
    {
      "EndpointUrl": "opc.tcp://opcsimulator:54855/OPCUA/Site2",
      "UseSecurity": false,
      "OpcNodes": [
        {
          "Id": "ns=1;s=STATUS",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "STATUS"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_GOOD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_GOOD"
        },
        {
          "Id": "ns=1;s=ITEM_COUNT_BAD",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_BAD"
        }
      ]
    }
 ]
```

Add any new server node at the end of the file, along with the three data nodes (`STATUS`, `ITEM_COUNT_GOOD`, `ITEM_COUNT_BAD`). The new node should look similar to:

```json
 {
      "EndpointUrl": "opc.tcp://<opc_server_name>:<opc_server_port>/<opc_server_path>",
      "UseSecurity": false,
      "OpcNodes": [
        {
          "Id": "<nodeid_for_STATUS>",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "STATUS"
        },
        {
          "Id": "<nodeid_for_ITEM_COUNT_GOOD>",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_GOOD"
        },
        {
          "Id": "<nodeid_for_ITEM_COUNT_BAD>",
          "OpcSamplingInterval": 1000,
          "OpcPublishingInterval": 5000,
          "DisplayName": "ITEM_COUNT_BAD"
        }
      ]
    }

```

Note that above sample sets `UseSecurity: false`, which is not recommended in production environments.

### Adding the Site Level Performance to the dashboard

The following dashboard panels require the running status of asset:

1. OEE Gauge
1. OEE History
1. Availability Gauge
1. Availability History
1. Performance Gauge
1. Performance History

Each of these panels use a mapping set, which is defined in the query below, meaning if `STATUS` is 101, 105 or 108, the dashboard will consider the asset to be relevant for the [KPI calculations](manufacturing-kpis.md).

```sql
StatusValuesForOn = [101,105,108]
```

Modify these values in each panel's query to reflect `STATUS` values that indicate the `RUNNING` state of any asset.

After modification, save the dashboard JSON file (`dashboard->settings->JSON Model`) under `modules\grafana\grafana-provisioning\dashboards` and rebuild deployment.

### Adding a new asset (complex scenario)

#### Configuring the OPC UA server

Configure the OPC UA server to publish any desired data points.

Note down the "NodeId" values for all three data points, which are used in the `publishedNodes.json` configuration file.

Configure the security aspects to make sure the solution has access.

#### Adding nodes to the solution

The `publishedNodes.json` configuration file contains the OPC UA nodes to be monitored by the OPC Publisher module. The file can be found in `modules\opcpublisher`. By default the configuration contains two simulators (see above) and three nodes for each simulator:

Add new node definitions including any security settings required. Note that the sample below sets `UseSecurity: false`, which is not recommended in production environments.

```json
[
    {
      "EndpointUrl": "opc.tcp://<opc_server_name>:<opc_server_port>/<opc_server_path>",
      "UseSecurity": false,
      "OpcNodes": [
        {
          "Id": "<nodeid_for_field1>",
          "OpcSamplingInterval": <sampling_interval>,
          "OpcPublishingInterval": <publishing_interval>,
          "DisplayName": "<display_name_for _field1>"
        },
        .
        .
      ]
    },
    .
    .
]

```

#### Modify how IoT messages are received

The edge-to-influx flow receives IoT messages and formats them into an upsert command for InfluxDB. The implementation below handles various differences between different OPC Publisher versions.

```javascript
//type checking
var getType = function (elem) {
    return Object.prototype.toString.call(elem).slice(8, -1);
};

function appendLeadingZeroes(n,digits){
  var s="";
  var start;
  if(n <= 9){
    start=1;
  }
  else if(n > 9 && n<= 99){
    start=2;
  }
  else if(n > 99){
    start=3;
  }

  for (i=start;i<digits;i++)
  {
    s = s + "0";
  }
  return s + n;
}

function formatDate(d){
return  d.getFullYear() + "-" +
        appendLeadingZeroes(d.getMonth() + 1,2) + "-" +
        appendLeadingZeroes(d.getDate(),2) + " " +
        appendLeadingZeroes(d.getHours(),2) + ":" +
        appendLeadingZeroes(d.getMinutes(),2) + ":" +
        appendLeadingZeroes(d.getSeconds(),2) + "." +
        appendLeadingZeroes(d.getMilliseconds(),3);
}

//process a single data point instance
var processNode = function (rnode) {

var tmpStr;

if (getType(rnode.Value) === 'Object')
{
    if (rnode.Value.SourceTimestamp !== undefined)
    {
        if(isNaN(new Date(rnode.Value.SourceTimestamp).getTime()))
             {rnode.Timestamp = new Date().toString(); }
        else {rnode.Timestamp=rnode.Value.SourceTimestamp;}
    }
    if (rnode.Value.Body !== undefined)
    {
        rnode.Value=rnode.Value.Body;
    }
    else if (rnode.Value.Value !== undefined)
    {
        rnode.Value=rnode.Value.Value;
    }
}

//make sure correct display name
if (rnode.DisplayName === null || rnode.DisplayName === undefined || rnode.DisplayName === '')
{
    tmpStr = rnode.NodeId.split("=");
    rnode.DisplayName=tmpStr[tmpStr.length-1];
}


if (rnode.DisplayName.indexOf("=")>=0)
{
    tmpStr = rnode.DisplayName.split("=");
    rnode.DisplayName=tmpStr[tmpStr.length-1];
}

if (rnode.ApplicationUri === null || rnode.ApplicationUri === undefined || rnode.ApplicationUri === '')
{
    tmpStr = rnode.NodeId.split("=");
    if(tmpStr[0].length>2){rnode.ApplicationUri=tmpStr[0].substring(0,tmpStr[0].length-2);}
        else {rnode.ApplicationUri=tmpStr[0];}
}

//make sure timestamp property exists
if (rnode.Timestamp === undefined){
    rnode.Timestamp = new Date().toString();
}

rnode.time = new Date(rnode.Timestamp).getTime()*1000000;

var new_payload =
    {
        measurement: "DeviceData",
        fields: {
            //field added in next statement
        },
        tags:{
            Source: rnode.ApplicationUri,
        },
        timestamp: rnode.time
    }
;

new_payload.fields[rnode.DisplayName]=rnode.Value;
return new_payload;
}

//main
if (getType(msg.payload) === 'Array'){
    for (index = 0; index < msg.payload.length; index++) {
        msg.payload[index] = processNode(msg.payload[index]);
    }
}
else
{
    var newnode = processNode(msg.payload);
    msg.payload = new Array(newnode);
}
return msg;

```

The resulting JSON is sent to InfluxDB:

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
* Use the `timestamp` value from the source OPC Server or create a separate value, according to your use case.

#### Modifying the dashboard: Site Level Performance

When changing data fields, the dashboard and all panels need to be re-designed and the respective queries modified. See [Manufacturing KPIs](/documentation/manufacturing-kpis.md) for a guidance on how the dashboards are built.
