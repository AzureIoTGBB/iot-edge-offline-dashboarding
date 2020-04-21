# IoT Edge Offline Dashboarding Background Information

As mentioned in the [readme](readme.md), the architecture for this solution utilizes four main components in addition to Azure IoT Hub.  Azure IoT Edge is utilized to orchestrate and manage modules at the edge in addition to providing capabilities for offline operation and message routing.  Node-RED is an open-source flow programming tool utilized to easily integrate and route messages from edge devices to InfluxDB.  InfluxDB is an open-source, time series database for storing device telemetry.  Lastly, Grafana is an open-source analytics and dashboarding tool for visualizing device telemetry. 

## Reasons for selecting this architecture

The main purpose of this solution is to provide an ability for machine operators to view dashboards at the edge regardless of whether the edge device was online or offline.  This is a natural scenario that IoT Edge supports.  In order to support dashboarding however, there was a need to also select both a storage component as well as a visualization component.  

### Storage Component

A number of storage solutions were reviewed and the team selected InfluxDB for the following reasons:

* Influx DB is a time series DB and as such is a natural fit for telemetry data from devices
* Open-source with a large community following
* Supports plugin to Grafana
* Node-RED libraries for easy integration
* Quick time to value and can be deployed as a Docker container
* Ranked #1 for time series DBs according to [DB-Engines](https://db-engines.com/en/system/InfluxDB) 

Although InfluxDB was chosen to support storage, other DBs were considered and could potentially be used as well.  For example, Graphite, Prometheus and Elasticsearch were also considered.  Azure Time Series insights was also considered but at the time of this activity was not yet available on Azure IoT Edge.

### Visualization Component

A number of visualization solutions were reviewed and the team selected Graphana for the following reasons:

* Open-source with a large community following
* This particular use case covers metric analysis vs log analysis
* Flexibility with support for a wide array of plugins to different DBs and other supporting tools
* Allows you to share dashboards across an organization
* Quick time to value and can be deployed as a Docker container

Although Graphana was chosen to support visualization and dashboarding, other tools were considered and could potentially be used as well.  For example, Kibana may be a better fit for visualization and analyzing of log files and is a natural fit if working with Eleasticsearch.  Chronograph was considered, but was limited to InfluxDB as a datasource.  PowerBI Server was also investigated, but lack of support for being able to containerize the PowerBI Server meant it could not be used with Azure IoT Edge.

### Integration Component

Node-RED was chosen as the tool to ease integration between IoT Edge and InfluxDB.  Although the integration component could be written in a number of programming languages and containerized, Node-RED was selected for the following reasons:

* Open-source with a large community following
* Readily available nodes for tapping into IoT Edge message routes
* Readily available nodes for integrating and inserting data into InfluxDB as well as many other DBs
* Large library of nodes to integrate with other tools and platforms
* Easy flow-based programming allows manipulation and massaging of messages before inserted into a DB.
* Can be deployed as a Docker container
