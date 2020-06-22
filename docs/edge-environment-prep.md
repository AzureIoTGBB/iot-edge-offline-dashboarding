# Prepping an Azure VM to run IoT Edge

If you already have a functioning, AMD64-Linux-based, IoT Edge box, you can skip to the [dashboarding sample prep](#dashboard-solution-preparation) section.

## Azure CLI

These instructions leverage the Azure Command Line Interface (CLI). To install the Azure CLI for your environment, follow the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) for your OS. Alternately, in the Azure Portal, you can use an [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart?view=azure-cli-latest) which has the CLI pre-installed (stop before the "Create a resource group" section).

## Deployment

To deploy, we use the newest version of the Azure IoT extension, called `azure-iot`. The legacy version is called `azure-iot-cli-ext`. You should only have one version installed at a time. You can use the command `az extension list` to validate the currently installed extensions.

Use `az extension remove --name azure-cli-iot-ext` to remove the legacy version of the extension.

Use `az extension add --name azure-iot` to add the new version of the extension.

### Create Resources

Create a resource group to manage all the resources used in this solution

```bash
az group create --name {resource_group} --location {datacenter_location}
```

Use following to create the IoT Hub resource. Detailed information can be found at: <https://docs.microsoft.com/en-us/azure/iot-edge/quickstart-linux>

```bash
az iot hub create  --resource-group {resource_group} --name {hub_name} --sku S1
```

Create a device identity for your IoT Edge device so that it can communicate with your IoT Hub. The device identity lives in the cloud, and you use a unique device connection string to associate a physical device to a device identity. Detailed information can be found at: <https://docs.microsoft.com/en-us/azure/iot-edge/how-to-register-device>

```bash
az iot hub device-identity create --hub-name {hub_name} --device-id myEdgeDevice --edge-enabled
```

Retrieve the connection string for your device, which links your physical device with its identity in IoT Hub.

```bash
az iot hub device-identity show-connection-string --device-id myEdgeDevice --hub-name {hub_name}
```

Copy the value of the `connectionString` key from the JSON output and save it. This value is the device connection string. You'll use this connection string to configure the IoT Edge runtime in the next section.

![Retrieve connection string from CLI output](../media/retrieve-connection-string.png)

We will use a virtual machine as our IoT Edge device. Microsoft-provided [Azure IoT Edge on Ubuntu](https://azuremarketplace.microsoft.com/marketplace/apps/microsoft_iot_edge.iot_edge_vm_ubuntu) virtual machine image has everything preinstalled to run Azure IoT Edge on a device. Accept the terms of use and create this virtual machine using the following command.

```bash
az vm image terms accept --urn microsoft_iot_edge:iot_edge_vm_ubuntu:ubuntu_1604_edgeruntimeonly:latest

az vm create --resource-group {resource_group} --name myEdgeVM --image microsoft_iot_edge:iot_edge_vm_ubuntu:ubuntu_1604_edgeruntimeonly:latest --admin-username azureuser --generate-ssh-keys
```

Use the edge device primary device connection string you noted above, to connect IoT Edge device to IoT Hub

```bash
az vm run-command invoke -g {resource_group} -n myEdgeVM --command-id RunShellScript --script "/etc/iotedge/configedge.sh '{device_connection_string}'"
```

Once this command finishes, SSH into your VM using the 'azureuser' user name and run

```bash
iotedge list
```

You should see the edgeAgent module running, indicating a successful setup.  

## Dashboard solution preparation

Before we leave the Edge VM side of things, there are a couple of prep items that need to be done besides installing and configuring IoT Edge.  

First, since the edge machine will need persistent storage for the InfluxDB database, we need to create a directory for the module to bind to.  Use the ssh command to login into your edge machine and run the following.

```bash
sudo mkdir /influxdata
sudo chmod 777 -R /influxdata
```

Next, we need to open the Grafana port, which by default is port 3000, on our VM.  Note that you likely wouldn't do this in production, as your "offline" clients will probably be on the same network as your IoT Edge box.  We only need to do this because we are running/testing on a VM in Azure.  From the Azure CLI, run the following command to open access

```bash
az vm open-port --resource-group {resource group} --name {edge vm name} --port 3000
```

You can now return to the [dashboarding sample](dashboarding-sample.md#deployment-of-the-sample) document and pick a deployment strategy
