# IoT Edge offline dashboarding sample

## About this sample

As discussed in the [readme](/readme.md) for this repo, we created a sample implementation of our offline dashboarding architecture. As a significant percentage of our customers who need offline dashboarding are manufacturers, that is the use case we chose to implement. In particular, we show the necessary data collection, calculations, and visualization of the Overall Equipment Effectiveness (OEE) metric, common to manufacturers. For a deep dive in the dashboard and calculations involved, please see [this document](manufacturing_kpis.md).

For guidance on how to customize the sample for other use cases, please see the [customization](#customizing-the-sample-for-other-use-cases) section below.

## Business Need

Smart Manufacturing provides new opportunities to improve inefficiencies across labor, processes, machinery, materials and energy across the manufacturing lifecycle.

Azure Industrial IoT provides hybrid-cloud based components to build the end to end industrial IoT platform to enable innovation and to optimize operational processes.

Most manufacturers start their journey by providing visibility across machines, processes, lines and factories through their unified industrial IoT platform. This is achieved by collecting data from manufacturing processes to provide end to end visibility.

Different stakeholders will then make use of that platform to cater their own needs e.g planning department doing global planning or engineers monitoring and fine-tuning production phases.

Operators and users that are responsible for monitoring of operations are at the top of industrial IoT stakeholders list. They are usually responsible for well-being of operations and processes and need to have access to information in real-time. On the other hand, we also know that means of communication (infrastructure) is less than perfect in many manufacturing facilities. Although, we can provide real time access in the industrial IoT platform, what would happen if communications to cloud is cut-off? In terms of data reliability, Azure IoT Edge ensures data is accumulated when communications to cloud is broken and sent to the industrial IoT platform when facility is restored. But how can users access real time information in the meanwhile?

There are two major points this sample implementation addresses:

* Give local machine operators the ability to view telemetry and Key Performance Indicators (KPIs) during intermittent or offline internet connection scenarios.
* View near real-time telemetry and KPIs without the latency of telemetry data traveling to the cloud first.

## Solution Architecture

The Offline Dashboards sample is built upon Azure IoT Edge technology. IoT Edge is responsible for deploying and managing lifecycle of a set of modules (described later) that make up Offline Dashboards sample.

Offline Dashboards run at the IoT Edge device continuously recording data that is sent from devices to IoT Hub

![offline dashboards 1](../media/OfflineDashboards_diag1.png)

The offline dashboarding sample contains 5 modules:

1. A Node-RED module that runs an OPC-UA simulator, that emulates sending data from two "sites"
2. The [OPC-UA Publisher](https://github.com/Azure/iot-edge-opc-publisher) module provided by Microsoft's Industrial IoT team, that reads OPC-UA data from the simulator and writes it to IoT Edge (via edgeHub)
3. A Node-RED module that collects data from OPC Publisher (via edgeHub) and writes that data into influxDB.
4. An InfluxDB module which stores data in time series structure
5. A Grafana module which serves data from InfluxDB in dashboards.

![offline dashboards 2](../media/OfflineDashboards_diag2.png)

## Understanding the sample data, calculations, and dashboard elements

As mentioned in the introduction, our sample dashboard provides meaningful calculations of the Overall Equipment Effectiveness (OEE) metric common to manufacturers. We recommend you review the [documentation](manufacturing_kpis.md) for those KPIs before proceeding to deploy the sample.

## Deployment of the sample

The first step in running the sample is to have a functioning, Linux-based IoT Edge instance (Windows support coming).  If you already have one, you can skip to the next step. If you do not, you can test the sample on an Azure VM running IoT Edge by following the instructions [here](edge-environment-prep.md).

Once you have a functioning IoT Edge environment, we are providing several options for deployment instructions, in both order of incrementing complexity, but also in order of increasing recommendation (for repeatability and being less error prone)

* [Manual](deployment-manual.md) - for manual deployment instructions leveraging the docker command line and the Azure Portal
* TODO:  -   ... TODO: pseudomanual with VS code or scripts
* [Azure DevOps](deployment-devops.md) - For integrating the build and deployment process into an Azure DevOps pipeline

## Customizing the sample for other use cases

### Component Configuration

Each of the components in the solution are driven by configuration files contained in and deployed via their corresponding Docker images. As seen later in the module deployment, we use an Azure DevOps pipeline to automate creation of the Docker images and inclusion of the correct configuration files for each solution component.  This allows you to update the dashboard, for example, by updating the corresponding dashboard configuration file and executing the pipeline.

TODO:  content coming....

### Connecting Assets/OPC Servers

#### Removing Simulators

- Modify publishedNodes.json file and remove two nodes below. Data will stop flowing into database.

```
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

```
DROP MEASUREMENT DeviceData
```

Note that edge-to-flux flow automatically creates measurement if it does not exists.

- Remove "opc-simulator" module from deployment

#### Adding a new asset (basic scenario)

If you have an OPC Server installed and connected to a real asset/equipment and you published 3 data points (STATUS, ITEM_COUNT_GOOD, ITEM_COUNT_BAD) from OPC Server you can follow steps below to onboard you new asset:

##### Configure your OPC UA Server

- Configure your OPC UA server to publish following data points with numeric data types.
  - STATUS (double)
  - ITEM_COUNT_GOOD (double)
  - ITEM_COUNT_BAD (double)
- Note "NodeId" values for all 3 data points to be used in publishedNodes.json file.
- Configure security 

##### Modify publishedNodes.json file 

publishedNodes.json  file indicates OPC UA nodes to be monitored by OPC Publisher module. The file can be found at modules\opc-publisher folder.  By default publishedNodes.json file lists two simulators and 3 nodes from each simulator: 

```
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

```
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

##### Modify Dashboard: Site Level Performance

Dashboard panels that require running status of asset are below

1. OEE Gauge
2. OEE History
3. Availability Gauge
4. Availability History
5. Performance Gauge
6. Performance History

Each of these panels use a mapping set defined in the beginning of query as below, meaning if STATUS is 101, 105 or 108 we will consider asset to be running for KPI calculations.

```
StatusValuesForOn = [101,105,108]
```

You would need to modify these values in each panel's query  to reflect STATUS values that indicate RUNNING state of your asset.

After modification, save dashboard JSON file (dashboard->settings->JSON Model) under "modules\grafana\grafana-provisioning\dashboards" and rebuild deployment. 

#### Adding a new asset (complex scenario)

##### Configure your OPC UA Server

- Configure your OPC UA server to publish any data points you would like.
- Note "NodeId" values for all data points to be used in publishedNodes.json file.
- Configure security 

##### Modify publishedNodes.json file 

 publishedNodes.json  file indicates OPC UA nodes to be monitored by OPC Publisher module. The file can be found at modules\opc-publisher folder. You may want to remove simulator as described above before moving forward.

Add new node definitions including any security settings you have configured. Below sample uses "UseSecurity: false" setting which is not recommended in production environments.

 

```
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

##### Modify Flow: edge-to-influx

edge-to-influx flow basically receives IoT message and formats it into an upsert command for influx.  Below implementation handles various differences between OPC Publisher versions.

```
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

```
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



##### Modify Dashboard: Site Level Performance

When you change data fields, dashboard and panels all need to be re-designed and queries modified.  See [Manufacturing KPIs](manufacturing_kpis.md) for a guidance on how dashboards are built. 







#### Connecting Other Devices