# Deploy the IoT Offline Dashboarding sample via VSCode

This document shows how to deploy the IoT Offline Dashboarding sample via [VS Code](https://code.visualstudio.com/). To ease the number of pre-requisites and tools to install, this repository takes advantage of the "[remote container](https://code.visualstudio.com/docs/remote/containers)" support in VS Code. It leverages the same IoT Edge Dev tools that the IoT Edge extensions (and Azure DevOps) use under the hood - without having to install it or its prerequisites locally.

**Table of contents**
* [Install prerequisites](#install-prerequisites)
* [Clone and open the repository](#clone-and-open-the-repository)
* [Configuring the sample](#configuring-the-sample)
* [Build and push the sample images](#build-and-push-the-sample-images)
* [Deploy to an IoT Edge device](#deploy-to-an-iot-edge-device)
* [See also](#see-also)

## Install prerequisites

Please install the following prerequisites:

* [Visual Studio Code](https://code.visualstudio.com/Download)
* [Docker](https://docs.docker.com/get-docker/)
* [Git](https://git-scm.com/downloads)

Once VS Code is running, click on "Extensions" in the left border navigation. Search for `remote-containers` and click "Install".

A Docker-compatible container repository is needed to hold the built Docker images. If not already available, set up an Azure Container Registry with these [instructions](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli#create-a-container-registry). Once created navigate to the "Access Keys" blade in the left navigation of the container registry settings and note down the username and password.

**Please also set up your Edge devices by going through the [edge environment setup](setup-edge-environment.md) document.**

## Clone and open the repository

Open VS Code and click on the "Source Control" icon int he left border navigation.

!["Source Control" icon int he left border navigation](/media/vscode-source-control.jpg)

Select "Clone Repository". Paste the URL of this [repository](http://github.com/azureiotgbb/iot-edge-offline-dashboading) into the top input bar and confirm.

Choose a folder into which to clone the repository and open it after the download is complete.

When opening the repository VS Code will recognize that it includes a development container, asking if the solution should be re-opened in that container. Choose yes.

VS Code will proceed to start all development containers. Click on the notification to see the progress in the output window. Confirm each request to share the repository and .azure folders.

After several minutes, the project will be opened in the development container.

## Configuring the sample

Before the sample can be built and pushed to an Edge device, it needs to be configured.

### Defining the IoT Hub connection string

Find the "AZURE IOT HUB" section in the left "Explorer" bar of VS Code and expand it. Select "More Actions" (...) and choose "Set IoT Hub Connection String" for the IoT Hub [created earlier](setup-edge-environment.md).

Alternatively use the `'iothubowner'` policy connection string with the following command from the Azure cli:

```bash
az iot hub show-connection-string -n {iot hub name} --policy-name iothubowner
```

Paste this connection string into VS Code.

> [!NOTE]
> This connection string is the primary authentication to an IoT Hub and should be kept secret.

### Set environment variables

A number of environment variables are required to build, push and deploy. If not already auto-generated, create a new file called `".env"` in the project root directory. Paste the following environment variables into the empty file. Make sure to enter your specific values:

```bash
CONTAINER_REGISTRY_USERNAME={container registry username}
CONTAINER_REGISTRY_PASSWORD={container registry password}
CONTAINER_REGISTRY_ADDRESS={container registry address}

GRAFANA_ADMIN_PASSWORD={desired grafana password}

CONTAINER_VERSION_TAG={image tag}
```

About these environment variables:
* The first three variables are the container registry values for the container registry. In case of an Azure Container Registry, these can be found on the Access Keys blade
* GRAFANA_ADMIN_PASSWORD is the the desired administrative password for the Grafana dashboard  (the default username is 'admin')
* CONTAINER_VERSION_TAG is the version tag for the created Docker image (e.g. '0.0.1' or '1.0.0', etc). This is used as the version tag on all created imagesappended with the processor architecture (e.g. myacr.azurecr.io/opcsimulator:0.0.1-amd64)

Save the new .env file.

## Build and push the sample images

With the setup done, building and pushing the images is straightforward.

Open a terminal window (CTRL-SHIFT-') and run the following:

```bash
docker login {container registry address} -u {user name} -p {password}
```

If the login is successful, right click on the `deployment.template.json` file and choose "Build and Push IoT Edge Solution".

The docker images for the sample will be built and pushed to your specified container registry.

## Deploy to an IoT Edge device

To deploy the new images to your IoT Edge box:

* Expand the "AZURE IOT HUB" pane from the bottom of the left Explorer view in VS Code
* Navigate to the desired IoT Edge device
* Right click and choose "Create Deployment for a single device"
* Navigate to the config folder, choose `deployment.amd64.json` and "Select Edge Deployment Manifest"

The deployment will be submitted to the IoT Hub, which pushes the deployment manifest to your IoT Edge device. To confirm the modules are created and active, run the following command on your Edge device:

```bash
sudo iotedge list
```

Confirm that all modules have been deployed. Note that it might take several minutes to deploy each module, depending on the speed of each Edge box's Internet connection.

Once confirmed that the modules are running, return to the [page on Grafana Dashboards](/documentation/dashboarding-sample.md#view-the-grafana-dashboard) to see and customize the dashboard.

## See also

* [Deploying manually](deployment-manual.md)
* [Deploying via Azure DevOps pipelines](deployment-devops.md)
