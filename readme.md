# IoT Edge Offline Dashboarding

This project provides a set of modules that can be used with Azure IoT Edge in order to perform dashboarding at the edge.  

The goal is to provide both guidance as well as a sample implementation to show how you can enable dashboards that run on the edge at sites in the field, while still sending data to the cloud for centralized reporting and monitoring.

The architecture for this solution is composed of the following components:

* [Azure IoT Edge](https://azure.microsoft.com/en-us/services/iot-edge/)
* [Node-RED](https://nodered.org/)
* [InfluxDB](https://www.influxdata.com/products/influxdb-overview/)
* [Grafana](https://grafana.com/grafana/)

For information on other potential "Dashboarding on the Edge" use cases, why this architecture was chosen, discussion of alternatives, please see next section.

This architecture and its components are intended to be general purpose and apply across a number of industries and use cases by simply switching out the data sources and dashboards. However, by far the customer segment where this need comes up the most often is manufacturing. Therefore the sample implementation below focuses on that use case.

### Solution Goals

The purpose of this solution is to provide both general purpose guidance for dashboarding on the edge as well as a sample implementation.  While our sample implementation focuses on manufacturing, there are plenty of other potential use cases for this technology.  Some examples include:

* retail stores that may need local dashboards for inventory or asset management
* warehouses that may need to manage the tracking and movement of product throughout the warehouse
* smart buildings who may need to manage energy or HVAC efficiency throughout the property
* "things that move" applications such as container or cruise ships that may need to operate for extended periods offline

The main thing in common in these scenarios is the potential need to not only send important 'site' data to the cloud for centralized reporting and analytics, but also the ability to continue local operations in the event of an internet outage.

Our goal is to demonstrate how this can be done for a specific manufacturing use case, but also give an example that can be re-used for other use cases by:

* replacing the data source(s) to be specific to the new use cases
* replacing the configuration files for the data ingestion and dashboards

### Solution Architecture

the architecture for this solution utilizes four main components in addition to Azure IoT Hub.  Azure IoT Edge is utilized to orchestrate and manage modules at the edge in addition to providing capabilities for offline operation and message routing.  Node-RED is an open-source flow programming tool utilized to easily integrate and route messages from edge devices to InfluxDB.  InfluxDB is an open-source, time series database for storing device telemetry.  Lastly, Grafana is an open-source analytics and dashboarding tool for visualizing device telemetry.

#### Reasons for selecting this architecture

The main purpose of this solution is to provide an ability for local operators to view dashboards at the edge regardless of whether the edge device was online or offline.  This is a natural scenario that IoT Edge supports.  In order to support dashboarding however, there was a need to also select both a storage component as well as a visualization component.  

#### Storage Component

A number of storage solutions were reviewed and the team selected InfluxDB for the following reasons:

* Influx DB is a time series DB and as such is a natural fit for telemetry data from devices
* Open-source with a large community following
* Supports plugin to Grafana
* Node-RED libraries for easy integration
* Quick time to value and can be deployed as a Docker container
* Ranked #1 for time series DBs according to [DB-Engines](https://db-engines.com/en/system/InfluxDB)

Although InfluxDB was chosen to support storage, other DBs were considered and could potentially be used as well.  For example, Graphite, Prometheus and Elasticsearch were also considered.  Azure Time Series insights was also considered but at the time of this activity was not yet available on Azure IoT Edge.

#### Visualization Component

A number of visualization solutions were reviewed and the team selected Grafana for the following reasons:

* Open-source with a large community following
* This particular use case covers metric analysis vs log analysis
* Flexibility with support for a wide array of plugins to different DBs and other supporting tools
* Allows you to share dashboards across an organization
* Quick time to value and can be deployed as a Docker container

Although Grafana was chosen to support visualization and dashboarding, other tools were considered and could potentially be used as well.  For example, Kibana may be a better fit for visualization and analyzing of log files and is a natural fit if working with Elasticsearch.  Chronograf was considered, but was limited to InfluxDB as a datasource.  PowerBI Server was also investigated, but lack of support for being able to containerize the PowerBI Server meant it could not be used directly with Azure IoT Edge. Additionally, PowerBI Server does not support the real-time "live" dashboaring required for this solution.

#### Integration Component

Node-RED was chosen as the tool to ease integration between IoT Edge and InfluxDB.  Although the integration component could be written in a number of programming languages and containerized, Node-RED was selected for the following reasons:

* Open-source with a large community following
* Readily available [nodes](https://github.com/iotblackbelt/noderededgemodule) for tapping into IoT Edge message routes
* Readily available nodes for integrating and inserting data into InfluxDB as well as many other DBs
* Large library of nodes to integrate with other tools and platforms
* Easy flow-based programming allows manipulation and massaging of messages before inserted into a DB.
* Can be deployed as a Docker container

## Solution Architecture

The Offline Dashboards sample is built upon Azure IoT Edge technology. IoT Edge is responsible for deploying and managing lifecycle of a set of modules (described later) that make up Offline Dashboards sample.

![](media/OfflineDashboards_diag.png)

Offline Dashboards runs at the IoT Edge device continuously recording data that is sent from devices to IoT Hub. It contains 3 modules:

1. A Node-Red module that collects data from OPC Publisher and writes that data into influxDB. Shout out to our IoT peers in Europe for the [IOT Edge nodered module](https://github.com/iotblackbelt/noderededgemodule) that enable this.
2. An influxDB module which stores data in time series structure
3. A Grafana module which serves data from influxDB in dashboards.

![image-20200529160206347](media/OfflineDashboards_diag0.png)

## About the sample solution

This sample implementation leverages data from two OPC-UA servers.  For many reasons, OPC-UA is Microsoft's recommended manufacturing integration technology, where possible. However, the OPC-UA publisher that generates data for the dashboard could be substituted with other data sources including modbus, MQTT, or other custom protocols.  

More Information about the sample solution can be found [here](/docs/manufacturing_kpis.md) 

Step by step deployment instructions can be found [here](/docs/deployment.md) 

