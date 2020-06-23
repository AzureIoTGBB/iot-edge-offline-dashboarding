# IoT Offline Dashboarding sample - manual deployment

This document shows how to deploy the sample dashboards via VS Code.  To ease the number of pre-requisites and tools you need to install, we chose to take advantage of the "[remote container](https://code.visualstudio.com/docs/remote/containers)" support in VS Code.   This let's us leverage the same IoT Edge Dev tool that the IoT Edge extension (and azure devops) uses under the covers, without having to install it or its prerequisites locally.

## Install prerequisites

While we are minimizing the number of pre-reqs, we still need a few

- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/Download)
- Remote Containers extension:  Once VS Code is running, click on Extensions in the left-nav and search for remote-containers and click Install

You will need a docker-compatible container repository to hold the docker images we will build. If you do not have one already, you can create an Azure Container Registry with these [instructions](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli#create-a-container-registry).  Note, once created, you'll need to navigate to the container registry and the "Access Keys" blade in the left nav and grab teh username and password, you'll need it later.

## Clone and open the repo

Open VS Code and click on the 'source control' icon on the left nav

![source control icon](/media/vscode-source-control.jpg)

and then click "Clone Repository".  In the entry bar that opens at the top of the screen, paste in the URL of this [repository](http://github.com/azureiotgbb/iot-edge-offline-dashboading) and hit {enter}.  

In the Select Folder dialog, choose a folder into which you want to clone the repository. VS Code will proceed to clone the repository locally and will pop-up a notification when complete asking if you want to open the newly cloned repo.  Do so.

When opened, you should receive another prompt noting that the repository includes a development container and asking if you want to re-open in that container.  Choose yes.

After the re-open, you will see a pop-up indication that the development container is being started.  You can click on the notification to see the progress in an output window. You will also get asked if it is ok to share the repo folder and the .azure folder with Docker. Do so.

After several minutes, the project will be opened in the development container.

## Sample development configuation

To build and push the sample solution, a couple of configuration items need to be done.

### Set IoT Hub Connection String

In the lower left corner of VS Code, you will see the "AZURE IOT HUB" section.  Expand it, click on the ellipsys (...), and chose "Set IoT Hub Connection String".  Here we need an 'IoT Hub-level' connection string. For dev purposes, you can use the 'iothubowner' policy connection string.  To retrieve that connection string, run the following command from the azure cli

```bash
az iot hub show-connection-string -n {iot hub name} --policy-name iothubowner
```

>Note:  remember, this connection string is the 'key to the kingdom' in regards to your IoT Hub. Please protect this key.

In the open box in VS Code, paste this connection string in and hit {enter}.

### Set environment variables

For the build, push, and deployment processes, we need a few environment variables set.  If VS Code did not do so, create a new file called ".env" at the root of the project. In that file, paste the following environment variables and set them to your specific desired values:

```bash
CONTAINER_REGISTRY_USERNAME={container registry username}
CONTAINER_REGISTRY_PASSWORD={container registry password}
CONTAINER_REGISTRY_ADDRESS={container registry address}

GRAFANA_ADMIN_PASSWORD={desired grafana password}

CONTAINER_VERSION_TAG={image tag}
```

- The first three values are the container registry values for your container registry. If you use/created a Azure Container Registry, these can be found on the Access Keys blade
- The GRAFANA_ADMIN_PASSWORD is the password that you wish to set as the administrative password on the grafana dashboard site we are deploying (the user-id is 'admin')
- the CONTAINER_VERSION_TAG is the version tag we want to use on the docker images we create  (e.g.  '0.0.1' or '1.0.0', etc).  We will use this as the version tag on all the images that we create, with the processor architecture appended  (e.g. myacr.azurecr.io/opcsimulator:0.0.1-amd64)

Save the .env file

You are now ready to build, push, and deploy the solution images.

## Build and Push the sample images

Now that the setup is done, building and pushing the image is straightforward.

Open a terminal window (CTRL-SHIFT-') and run

```bash
docker login {container registry address} -u {user name} -p {password}
```

if login is successful, then right click on deployment.template.json file and choose "Build and Push IoT Edge Solution"

The docker images for the sample will be built and pushed to your specified container registry.

## Deploy to IoT Edge

To deploy our new images to your IOT Edge box,

- expand the "AZURE IOT HUB" pane from the bottom left corner of VS Code
- Navigate to your IoT Edge box
- Right click and choose "Create Deployment for a single device"
- navigate into the config folder, chose deployment.amd64.json, and choose "Select Edge Deployment Manifest"
  
The deployment will be submitted to IoT Hub which will, in turn, push the deployment manifest to your IoT Edge box.  To confirm the modules are created and running, run

```bash
sudo iotedge list
```

on your Edge box. Depending on the Internet speed of the connection to your Edge box, you may need to run it a few times to allow time for all the containers to be pulled down.

Once you have confirmed your modules are running, return to the [View the Grafana Dashboards](dashboarding-sample.md#view-the-grafana-dashboard) section to see your sample dashboards.
