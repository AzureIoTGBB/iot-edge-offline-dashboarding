# Customize Node-RED Flows

In order to customize the Node-RED flows, you will need to be able to access the Node-RED flow editor.  There are two Node-RED flows in this project: "opcsimulator" and "edgetoinfluxdb."  

## Access the Node-RED Flows
To access the flow for the opcsimulator, go to http://edgeipaddress:1880/ and for the edgetoinfluxdb flow go to http://edgeipaddress:1881/.  Don't forget to open ports 1880 and 1881 on your edge device in order to reach those Node-RED flows.  Login using the user name "reader" and the password "NRReader123".  This will allow you to browse the flows in read-only mode (no flow deployment).  If you want to be able to modify the flows, you will need to create a new admin password.  Refer to the following sections for instructions.   

## Generate New Admin Passwords
The flows have a default admin password set.  In order to view and modify the flows you will need to generate a password hash and update the hashed password in the settings.js file of both modules.  You will then need to redeploy the modules.  More information about securing Node-RED can be found [here](https://nodered.org/docs/user-guide/runtime/securing-node-red).  

### Steps to generate and update Node-RED admin passwords
1.  SSH into your edge machine
2.  Get the container ID of the "edgetoinfluxdb" module:
    ```bash
    sudo docker ps
    ```
3.  SSH into the container:
    ```bash
    sudo docker exec -it <Container_ID> bash
    ```
4.  In the container shell, run the following to create a password hash:
    ```bash
    node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" <Your_New_Password>
    ```
5.  Copy the resulting hashed password for use in the next steps.
6.  In your forked repo, locate the files opcsimulator/settings.js and edgetoinfluxdb/settings.js.
7.  Locate the following section of each file and update the password hash with the password hash you generated in step 4.
    ```bash
    adminAuth: {
       type: "credentials",
       users: [{
           username: "admin",
           password: "$2a$08$iiR32/SpJlZkZQ3MGEtd8OuC22n5qtvO/msabc123abc123abc123",
           permissions: "*"
       },
    ```
8.  Commit your changes and build\redeploy your solution.
