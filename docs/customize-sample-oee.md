
# Customizing the offline dashboarding solution

## Component Configuration

Each of the components in the solution are driven by configuration files contained in and deployed via their corresponding Docker images. As seen earlier in the deployment sections, all configuration of the solution is done via files included in the Docker images.  This allows you to update the dashboard, for example, by updating the corresponding dashboard configuration file and redeploying (possibly 'at scale') the corresponding images.

## Connecting Assets/OPC Servers

### Removing Simulators

- Modify publishedNodes.json file and remove two nodes below. Data will stop flowing into database.

```json
 [
     {
      "EndpointUrl": "opc.tcp://opc-simulator:54845/OPCUA/Site1",
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
      "EndpointUrl": "opc.tcp://opc-simulator:54855/OPCUA/Site2",
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

- Delete measurement to remove old records from influxdb

```sql
DROP MEASUREMENT DeviceData
```

Note that edge-to-flux flow automatically creates measurement if it does not exists.

- Remove "opc-simulator" module from deployment

### Adding a new asset (basic scenario)

If you have an OPC Server installed and connected to a real asset/equipment and you published 3 data points (STATUS, ITEM_COUNT_GOOD, ITEM_COUNT_BAD) from OPC Server you can follow steps below to onboard you new asset:

#### Configure your OPC UA Server

- Configure your OPC UA server to publish following data points with numeric data types.
  - STATUS (double)
  - ITEM_COUNT_GOOD (double)
  - ITEM_COUNT_BAD (double)
- Note "NodeId" values for all 3 data points to be used in publishedNodes.json file.
- Configure security

#### Modify publishedNodes.json file

publishedNodes.json  file indicates OPC UA nodes to be monitored by OPC Publisher module. The file can be found at modules\opc-publisher folder.  By default publishedNodes.json file lists two simulators and 3 nodes from each simulator:

```json
  [
     {
      "EndpointUrl": "opc.tcp://opc-simulator:54845/OPCUA/Site1",
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
      "EndpointUrl": "opc.tcp://opc-simulator:54855/OPCUA/Site2",
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

To edit the file add a new server node at the end of the file along with 3 nodes (STATUS, ITEM_COUNT_GOOD, ITEM_COUNT_BAD). The new node should look similar to

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

Note that above sample uses "UseSecurity: false" setting which is not recommended in production environments.

### Modify Dashboard: Site Level Performance

Dashboard panels that require running status of asset are below

1. OEE Gauge
2. OEE History
3. Availability Gauge
4. Availability History
5. Performance Gauge
6. Performance History

Each of these panels use a mapping set defined in the beginning of query as below, meaning if STATUS is 101, 105 or 108 we will consider asset to be running for KPI calculations.

```sql
StatusValuesForOn = [101,105,108]
```

You would need to modify these values in each panel's query  to reflect STATUS values that indicate RUNNING state of your asset.

After modification, save dashboard JSON file (dashboard->settings->JSON Model) under "modules\grafana\grafana-provisioning\dashboards" and rebuild deployment.

### Adding a new asset (complex scenario)

#### Configure your OPC UA Server

- Configure your OPC UA server to publish any data points you would like.
- Note "NodeId" values for all data points to be used in publishedNodes.json file.
- Configure security

#### Modify publishedNodes.json file

 publishedNodes.json  file indicates OPC UA nodes to be monitored by OPC Publisher module. The file can be found at modules\opc-publisher folder. You may want to remove simulator as described above before moving forward.

Add new node definitions including any security settings you have configured. Below sample uses "UseSecurity: false" setting which is not recommended in production environments.

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

#### Modify Flow: edge-to-influx

edge-to-influx flow basically receives IoT message and formats it into an upsert command for influx.  Below implementation handles various differences between OPC Publisher versions.

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

The result JSON that is sent to influx looks like below

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

Here are a few tips creating JSON message

- It is a JSON array which may contain multiple tuples
- "measurement" is similar to table name, you may insert data into different measurements.
- "fields" are actual metrics/data points that are identified by time stamp and tag values
- You may use multiple field values in a single message. You may also use separate messages for different fields. As long as, timestamp and tag values are the same, these are considered to be part of same tuple.
- "tags" are values that describe the metric. Such as which asset it is or where it is located. You can use this flow to further contextualize your data by accessing other LOB systems and merging data into same tuple as a tag.
- You can use timestamp value from source OPC Server or create your own value here, according to your solution requirements.  

#### Modify Dashboard: Site Level Performance

When you change data fields, dashboard and panels all need to be re-designed and queries modified.  See [Manufacturing KPIs](/docs/manufacturing_kpis.md) for a guidance on how dashboards are built.
