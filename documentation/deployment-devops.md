# Deploy sample offline dashboards via Azure Devops pipeline

This document describes how to set up an Azure DevOps pipeline to deploy the sample pipeline. This would typically be for ensuring you have a repeatable development, build, and deployment process, as well as to test deployment to multiple IoT Edge devices 'at scale'

## Prep Edge boxes and IoT Hub

Our DevOps pipeline is going to target "multiple" Edge boxes (even if you only want to test with one).  Follow the [Edge Environment Prep](/documentation/edge-environment-prep.md) document to prep as many Edge devices as you want.

The way we are going to target our devices is via a 'tag' in the Edge devices [Device Twin](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins#device-twins). The DevOps pipeline creates an IoT Hub [Automatic Deployment](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-automatic-device-management) that targets any Edge device that has the specified 'tag' in its twin.  

To create the tag, navigate to your IoT Hub and choose "IoT Edge" from the left nav. Click on your IoT Edge device and then "Device Twin" from the top links in the blade. Create a 'tag' in the device twin for your Edge device, for example:

```json
{
(((rest of device twin removed for brevity)))

"tags":
    {"dashboard":true},

(((rest of device twin removed for brevity)))
}
```

save the device twin. Repeat this process for any additional IoT Edge devices you want to target with our pipeline.

## Fork the repo

We host our DevOps pipeline details in our main github repo for the dashboarding sample. When you work with it, you will likely, at a minimum, want to change the target conditions.To keep from trying to clobber our main repo, you should do a github [fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) of the solution to your own github repo.  That way you can make any change you desire to the pipeline.

## Set up Azure DevOps organization and Project

To set up the Azure DevOps pipeline, the first thing you need to do, if you don't already have one, it set up an [organization](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops) and [project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page) in Azure Devops  (skip the 'Add a Repository to your Project -- we will manage our repo in github)

Before we start our pipeline, there are two project-level preliminary tasks we need to handle

### install GitVersion add-in

For convenience (and coolness!), we use [GitVersion](https://marketplace.visualstudio.com/items?itemName=gittools.usegitversion) to automatically derive our image version tags from our repository.  Use the "Get it free" button on the link above to install the add-in into our organization

### Create Service Connection to Azure

We need to create a Service Connection to Azure to allow DevOps to push images and create deployments in our Azure subscription.

- In the lower left corner, choose "Project Settings"
- From the left-nav, choose "Service Connections"
- Click "New Service Connection"
- Choose "Azure Resource Manager" and hit "next"
- Choose "Service Principal (automatic)" then "next"
- Choose your Azure subscription from the dropdown
  - in environments where you may not have subscription-level permissions, you may have to also select the specific Resource Group where you deployed your IoT Hub and ACR instance
- give your service connection and name and hit Save

## Create DevOps pipeline

Click on Pipelines from the left-nav and then click "Create Pipeline"

- From the "Where is your code?" screen, choose Github.  
  - You may see a screen asking you to "Authenticate to authorize access" to your github repo
- From the "Select a repository" screen, select your fork you created above.
  - You may see a screen asking you to "Approve & Install Azure Pipelines".  Choose Approve and Install
- From the "review your pipeline" screen, click the down-arrow next to Run and click "Save"  (we aren't ready to run yet, as we need to add some variables first)

### Update pipeline target condition

At the very bottom of the pipeline, you'll find the line

```yaml
        targetcondition: '*'
```

This tells the pipeline what we want the target condition for our automated deployment to be. By default, we target every Edge box in our IoT Hub.

Earlier we added some target tags to our Edge box's device twin that we want to target. Edit the targetcondition to target that tag.  For example, using our example tag from above, the targetcondition would look like this

```yaml
        targetcondition: 'tags.dashboard=true'
```

Save your pipeline

### Set pipeline environment variables

To make our pipeline as general as possible, much of the config is supplied in the form of environment variables.  To add these variables, click on "Variables" in the upper right hand corner of the Edit Pipeline screen. Add the following variables and values:

- ACR_NAME:  this is the 'short name' of our Azure Container Registry (the part before .azurecr.io)
- ACR_RESOURCE_GROUP:  the name of the resource group in azure that contains your Azure Container Registry
- AZURE_SERVICE_CONNECTION:  The name of the azure service connection you created above
- AZURE_SUBSCRIPTION_ID:  the subscription ID of the Azure subscription you are using
- GRAFANA_ADMIN_PASSWORD:  the desired administrator password for the grafana dashboard web app when deployed
- IOT_HUB_NAME:  The name of your IOT Hub  (short name, without the .azure-devices.net)
- DEPLOYMENT_TARGET_CONDITION:  the target condition you want to use for your deployment. For example, based on the tag example used above, you could use 'tags.dashboard=true'.

Click "Save"

## Execute pipeline

The pipeline is set to trigger on commits to the master branch of your github repo. However, for testing, we'll run it manually.

Click on Run in the upper right hand corner to kick off a manual run of the pipeline. The pipeline has "Build" and "Release" stages.  Click on the "Build" stage to open up the details of the run so you can watch it execute

## Verify successful deployment

SSH into your IoT Edge box and run

```bash
sudo iotedge list
```

to confirm that your modules have deployed (it may take several minutes to deploy, depending on the speed of your Edge box's Internet connection)

Once you have confirmed your modules are running, return to the [View the Grafana Dashboards](/documentation/dashboarding-sample.md#view-the-grafana-dashboard) section to see your sample dashboards.
