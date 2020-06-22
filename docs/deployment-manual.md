# IoT Offline Dashboarding sample - manual deployment

## Build Module Images

Before we can deploy the edge modules needed for this solution, we need to build the module images using the Dockerfiles found in this repository.  Once built, the images need to be placed into a container registry.

Clone this repository to your local machine.

```bash
git clone https://github.com/AzureIoTGBB/iot-edge-offline-dashboarding.git
```

Next, we need to build the image for each module and push it to a docker container registry.  Replace {registry} in the commands below with your own registry location.  If you do not have one already, you can create an Azure Container Registry with these [instructions](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli#create-a-container-registry).  Note, once created, you'll need to navigate to the container registry and the "Access Keys" blade in the left nav and grab teh username and password, you'll need it later.

```bash
sudo docker login {registry}

cd iot-edge-offline-dashboarding/modules/edge-to-influxdb
sudo docker build --tag {registry}/edge-to-influxdb:1.0 .
sudo docker push {registry}/edge-to-influxdb:1.0

cd ../grafana
sudo docker build --tag {registry}/grafana:1.0 .
sudo docker push {registry}/grafana:1.0

cd ../influxdb
sudo docker build --tag {registry}/influxdb:1.0 .
sudo docker push {registry}/influxdb:1.0

cd ../opc-publisher
sudo docker build --tag {registry}/opc-publisher:1.0 .
sudo docker push {registry}/opc-publisher:1.0

cd ../opc-simulator
sudo docker build --tag {registry}/opc-simulator:1.0 .
sudo docker push {registry}/opc-simulator:1.0
```

## Deploy Modules

Now that we have all five module images in a container registry, we can deploy instances of these module images to an edge machine using IoT Hub.

Navigate to your IoT Hub in the Azure portal go to IoT Edge.  You should see your edge device.  Click on your edge device and then click "Set Modules."  In the Container Registry Credentials, put the name, address, user name and password of the registry container you used in the "Build Module Images" section of this readme.

In the IoT Edge Modules section, click the "+ Add" button and select "IoT Edge Module."  For IoT Edge Module Name put "edge-to-influxdb" and for Image URI put {registry}/edge-to-influxdb:1.0.  Be sure to replace {registry} with your own registry address.  Switch to the "Container Create Options and place the following JSON into the create options field.

```json
{
    "HostConfig": {
        "PortBindings": {
            "1880/tcp": [
                {
                    "HostPort": "1881"
                }
            ]
        }
    }
}
```

Click the "Add" button to complete the creation of the module to be deployed.  We now need to do this for the other four remaining modules.  The following are the property values to specify for each module.

Module grafana:

```json
IoT Edge Module Name: grafana
Image URI: {registry}/grafana:1.0
Environment Variable:
    Name: GF_SECURITY_ADMIN_PASSWORD
    Value: {password}
Container Create Options:
{
    "HostConfig": {
        "PortBindings": {
            "3000/tcp": [
                {
                    "HostPort": "3000"
                }
            ]
        }
    }
}
```

Module influxdb:

```json
IoT Edge Module Name: influxdb
Image URI: {registry}/influxdb:1.0
Container Create Options:
{
    "HostConfig": {
        "Binds": [
            "/influxdata:/var/lib/influxdb"
        ],
        "PortBindings": {
            "8086/tcp": [
                {
                    "HostPort": "8086"
                }
            ]
        }
    }
}
```

Module opc-publisher:

```json
IoT Edge Module Name: opc-publisher
Image URI: {registry}/opc-publisher:1.0
Container Create Options:
{
    "Hostname": "publisher",
    "Cmd": [
        "--pf=/app/pn.json",
        "--aa"
    ]
}
```

Module opc-simulator:

```json
IoT Edge Module Name: opc-simulator
Image URI: {registry}/opc-simulator:1.0
Container Create Options:
{
    "HostConfig": {
        "PortBindings": {
            "1880/tcp": [
                {
                    "HostPort": "1880"
                }
            ]
        }
    }
}
```

You should now have the following in your set modules dialog:

![Edge Modules](../media/edge-modules.png)

Next, we need to establish a route in the "Routes" tab.  Click on the "Routes" tab and add the following route with the name "opc":

```bash
FROM /messages/modules/opc-publisher/* INTO BrokeredEndpoint("/modules/edge-to-influxdb/inputs/input1")
```

![Edge Routes](../media/edge-routes.png)

You are now ready to deploy the modules to your edge machine.  Click the "Review + Create" button and then the "Create" button.  This will kick off the deployment.  If all goes well you should see all modules running after several minutes.  IoT Edge Runtime Response should be "200 -- Ok" and you should see all modules runtime status as "running."

![Edge Success](../media/edge-success.png)

Once you have confirmed your modules are running, return to the [View the Grafana Dashboards](dashboarding-sample.md#view-the-grafana-dashboard) section to see your sample dashboards.
