# Deploy the IoT Offline Dashboarding sample via Azure Devops pipelines

This document describes how to set up an Azure DevOps pipeline to deploy the IoT Offline Dashboarding sample. Chose this option to ensure a conitnuous, repeatable development, build, and deployment process, as well as having the ability to test the deployment to multiple IoT Edge devices at scale.

**Table of contents**
* [Preparation of Edge boxes and IoT Hub](#preparation-of-edge-boxes-and-iot-hub)
* [Forking the repository](#forking-the-repository)
* [Setting up an Azure DevOps organization and project](#setting-up-an-azure-devops-organization-and-project)
* [Creating the DevOps pipeline](#creating-the-devops-pipeline)
* [Executing the pipeline](#executing-the-pipeline)
* [Verify successful deployment](#verify-successful-deployment)
* [See also](#see-also)

## Preparation of Edge boxes and IoT Hub

The DevOps pipeline is going to target multiple Edge boxes.

**Please start by setting up your Edge devices by going through the [edge environment setup](setup-edge-environment.md) document.**

These devices will be targeted via a `tag` in the Edge devices [Device Twin](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins#device-twins). The DevOps pipeline creates an IoT Hub [automatic deployment](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-automatic-device-management) that targets any Edge devices that have the specified `tag` in their device twin.

To create such a tag, navigate to the IoT Hub and choose "IoT Edge" in the navigation. Click on the respective IoT Edge device and select "Device Twin" on the top left of the blade. Create a `tag` in the device twin for your Edge device, for example:

```json
{
(((rest of device twin removed for brevity)))

"tags":
    {"dashboard":true},

(((rest of device twin removed for brevity)))
}
```

Save the device twin after the change. Repeat this process for any additional IoT Edge devices that should be targeted with the pipeline.

## Forking the repository

The DevOps pipeline details for the sample are included in [the github repository](https://github.com/AzureIoTGBB/iot-edge-offline-dashboarding).

 Do a GitHub [fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) of the repository to your own workspace. After that, continue making changes to the pipeline configuration, for example changing the target conditions.

## Setting up an Azure DevOps organization and project

An Azure DevOps pipeline is always part of a [project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page), which is part of an [organization](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops). Follow the instructions on the given websites, but skip the 'Add a Repository to your Project' part since this is managed on GitHub.

Before adding the pipeline there are two project-level preliminary tasks.

### Install the GitVersion add-in

[GitVersion](https://marketplace.visualstudio.com/items?itemName=gittools.usegitversion) can be used to automatically derive image version tags from a repository. Use the "Get it free" button on the link above to install the add-in into the organization.

### Create a service connection to Azure

A service connection to Azure allows DevOps to push images and create deployments for an Azure subscription.

* In the lower left corner of the pipelin settings, choose "Project Settings"
* From the left navigation, choose "Service Connections"
* Click "New Service Connection"
* Choose "Azure Resource Manager" and hit "next"
* Choose "Service Principal (automatic)" then "next"
* Choose an Azure subscription from the dropdown
  * (For environments where you may not have subscription-level permissions, you may have to also select the specific Resource Group where you deployed your IoT Hub and ACR instance)
* Add a name for the service connection and hit Save

## Creating the DevOps pipeline

Click on Pipelines from the left-nav and then select "Create Pipeline".

* From the "Where is your code?" screen, choose Github
  * You may see a screen asking for authentication: "Authenticate to authorize access"
* From the "Select a repository" screen, select the fork created above
  * Select "Approve & Install Azure Pipelines" if required
* From the "review your pipeline" screen, click the down-arrow next to Run and click "Save" - note that a number of variables need to be added before the first run

### Set the pipeline environment variables

To make the pipeline as generic as possible, much of the config is supplied in the form of environment variables. To add these variables, click on "Variables" in the upper right hand corner of the "Edit Pipeline" screen. Add the following variables and values:

* ACR_NAME: This is the 'short name' of our Azure Container Registry (the part before .azurecr.io)
* ACR_RESOURCE_GROUP: The name of the resource group in Azure that contains the Azure Container Registry
* AZURE_SERVICE_CONNECTION: The name of the Azure service connection created above
* AZURE_SUBSCRIPTION_ID: The ID of the used Azure subscription
* GRAFANA_ADMIN_PASSWORD: The desired administrator password for the Grafana dashboard web app when deployed
* IOT_HUB_NAME: The name of the connected Azure IoT Hub (short name, without the .azure-devices.net)
* DEPLOYMENT_TARGET_CONDITION: The target condition to use for the deployment. This is in line with the target tags for the Edge box's device twin. Based on the tag used above, the value would be 'tags.dashboard=true'.
* Click "Save"

## Executing the pipeline

The pipeline is set to trigger on commits to the master branch of the GitHub repository. However for testing it can be run manually.

Click on "Run" in the upper right hand corner to start the manual execution of the pipeline. The pipeline has "Build" and "Release" stages. Click on the "Build" stage to open the detail view while running.

## Verify successful deployment

SSH into your IoT Edge box and run:

```bash
sudo iotedge list
```

Confirm that all modules have been deployed. Note that it might take several minutes to deploy each module, depending on the speed of each Edge box's Internet connection.

Once confirmed that the modules are running, return to the [page on Grafana Dashboards](/documentation/dashboarding-sample.md#view-the-grafana-dashboard) to see and customize the dashboard.

## See also

* [Deploying manually](deployment-manual.md)
* [Deploying via VSCode](deployment-vscode.md)
