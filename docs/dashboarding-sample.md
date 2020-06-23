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

The first step in running the sample is to have a functioning, Linux-based IoT Edge instance (Windows support coming).  You can set one up by following the instructions [here](edge-environment-prep.md).

Once you have a functioning IoT Edge environment, we are providing several options for deployment instructions, in both order of incrementing complexity, but also in order of increasing recommendation (for repeatability and being less error prone)

* [Manual](deployment-manual.md) - for manual deployment instructions leveraging the docker command line and the Azure Portal
* TODO:  -   ... TODO: pseudomanual with VS code or scripts
* [Azure DevOps](deployment-devops.md) - For integrating the build and deployment process into an Azure DevOps pipeline

### View the Grafana dashboard

Now that the edge modules are successfully running, you can view the running Grafana dashboard. Replace the {ip-address} in the following link with your own VM ip address and navigate to that site:

```http
http://{ip-address}:3000/
```

Login to Grafana using "admin" as user name and the password you specified in the "GF_SECURITY_ADMIN_PASSWORD" environment variable you created in grafana module options.  

> NOTE:  There is currently a bug in this sample. For some reason, the data source details are deployed correctly, but not 'enabled'. This will cause your dashboard to complain with an error and not show any data.  
>
> For now, once you have logged into Grafana, click the gear icon on the left-hand panel and select data sources.  You should see the "myinfluxdb" data source.  Click on it to navigate into the settings.  Click the "Save & Test" button at the bottom.  If things are working properly you should see "Data source connected and database found."

Next, hover over the dashboard icon in the left side panel and click "Manage."  You should see several OOE related dashboards under the General folder.  Click on the "Site Performance" dashboard to get started.  You should see the fully running dashboard like below:

![Grafana Dashboard](/media/grafana-dash.png)

Feel free to explore the other dashboards available.

## Customizing the sample

Inevitably, you will likely want to customize the sample solution to fit your unique business needs.  

If your use case is manufacturing/OEE and you are looking to change the data sources (perhaps from the simulator to real equipment),this [document](customize-sample-oee.md) discusses the process and options.

If your use case is something entirely different, this [document](customize-sample-other.md) gives a high level overview of the process involved.

## Known issues

There are a few known issues with the sample to be aware of

* When deploying grafana, the pre-configured datasource (myinfluxdb) is property configured, but that configuration isn't 'active'.  You'll see in the deployment information above that you have to manually navigate there and click "Save & Test" to activate it before your dashboards will work
* The deployment of Grafana doesn't currently work with backing, host-based storage.  This means that any changes made to Grafana (users, dashboards, etc) are lost if the container is removed or replaced
