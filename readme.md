# IoT Edge Offline Dashboarding

This project provides a set of modules that can be used with Azure IoT Edge in order to perform dashboarding at the edge.  There are two major points this project addresses:

* Give local machine operators the ability to view telemetry and Key Performance Indicators (KPIs) during intermittent or offline internet connection scenarios.
* View near real-time telemetry and KPIs without the latency of telemetry data traveling to the cloud first.

The architecture for this solution is composed of the following components:

* [Azure IoT Edge](https://azure.microsoft.com/en-us/services/iot-edge/)
* [Node-RED](https://nodered.org/)
* [InfluxDB](https://www.influxdata.com/products/influxdb-overview/)
* [Grafana](https://grafana.com/grafana/)

For information on why this architecture was chosen and discussion of alternatives, please see [background](background.md).

# Getting Started

To get started do the following...

### Prerequisites

Prerequisites...

```
Example Prerequisite...
```

# Business Need

Smart Manufacturing provides new opportunities to improve inefficiencies across labor, processes, machinery, materials and energy across manufacturing lifecycle. 

Azure Industrial IoT provides hybrid-cloud based components to build the end to end industrial IoT platform to enable innovation and to optimize operational processes.

Most manufacturers start their journey by providing visibility across machines, processes, lines, factories through their unified industrial IoT platform. This is achieved by collecting data from manufacturing processes to provide end to end visibility.

Different stakeholders will then make use of that platform to cater their own needs e.g planning department doing global planning engineers monitoring and fine-tuning production phases. 

Operators and users that are responsible for monitoring of operations are at the top of industrial IoT stakeholders list. They are usually responsible for well-being of operations and processes and need to have access to information in real-time. On the other hand, we also know that means of communication (infrastructure) is less than perfect in many manufacturing facilities. Although, we can provide real time access in the industrial IoT platform, what would happen if communications to cloud is cut-off? In terms of data reliability, Azure IoT Edge ensures data is accumulated when communications to cloud is broken and sent to the industrial IoT platform when facility is restored. But how can users access real time information in the meanwhile?

# The Solution

The Offline Dashboards solution is built upon Azure IoT Edge technology. IoT Edge is responsible for deploying and managing lifecycle of a set of modules (described later) that make up Offline Dashboards solution.

Offline Dashboards run at the IoT Edge device continuously recording data that is sent from devices to IoT Hub

![image-20200421144351244](docs/OfflineDashboards_diag1)





Offline Dashboards contains 3 modules:

1. A Node-Red module that collects data from OPC Publisher and writes that data into influxDB,
2. An influxDB module which stores data in time series structure,
3. A Grafana module which serves data from influxDB in dashboards.

![image-20200421144937520](docs/OfflineDashboards_diag2)





# Deployment

We the newest version of the Azure IoT extension, called `azure-iot`. The legacy version is called `azure-iot-cli-ext`.You should only have one version installed at a time. You can use the command `az extension list` to validate the currently installed extensions.

Use `az extension remove --name azure-cli-iot-ext` to remove the legacy version of the extension.

Use `az extension add --name azure-iot` to add the new version of the extension.

To see what extensions you have installed, use `az extension list`.

## Create Resources

Create a resource group to manage all the resources used in this solution

```
az group create --name {resource_group} --location {datacenter_location}
```



Use following to create the IoT Hub resource. Detailed information can be found at: https://docs.microsoft.com/en-us/azure/iot-edge/quickstart-linux

```
az iot hub create  --resource-group {resource_group} --name {hub_name} --sku S1
```

Create a device identity for your IoT Edge device so that it can communicate with your IoT hub. The device identity lives in the cloud, and you use a unique device connection string to associate a physical device to a device identity. Detailed information can be found at: https://docs.microsoft.com/en-us/azure/iot-edge/how-to-register-device

```
az iot hub device-identity create --hub-name {hub_name} --device-id myEdgeDevice --edge-enabled
```

Retrieve the connection string for your device, which links your physical device with its identity in IoT Hub.

```
az iot hub device-identity show-connection-string --device-id myEdgeDevice --hub-name {hub_name}
```

Copy the value of the `connectionString` key from the JSON output and save it. This value is the device connection string. You'll use this connection string to configure the IoT Edge runtime in the next section.

![Retrieve connection string from CLI output](docs\retrieve-connection-string.png)

We will use a virtual machine as your IoT Edge device. Microsoft-provided [Azure IoT Edge on Ubuntu](https://azuremarketplace.microsoft.com/marketplace/apps/microsoft_iot_edge.iot_edge_vm_ubuntu) virtual machine image has everything preinstalled to run Azure IoT Edge, which preinstalls everything you need to run IoT Edge on a device. Accept the terms of use and create this virtual machine using the following command.

```
az vm image terms accept --urn microsoft_iot_edge:iot_edge_vm_ubuntu:ubuntu_1604_edgeruntimeonly:latest

az vm create --resource-group {resource_group} --name myEdgeVM --image microsoft_iot_edge:iot_edge_vm_ubuntu:ubuntu_1604_edgeruntimeonly:latest --admin-username azureuser --generate-ssh-keys
```

Use the edge device primary device connection string you noted above, to connect IoT Edge device to IoT Hub

```
az vm run-command invoke -g {resource_group} -n myEdgeVM --command-id Run	ShellScript --script "/etc/iotedge/configedge.sh '{device_connection_string}'"
```

## Deploy Modules