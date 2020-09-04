# Start with upstream node-red
FROM nodered/node-red

# Copy package.json to the WORKDIR so npm builds all
# of your added modules for Node-RED
RUN npm install node-red-contrib-influxdb
RUN npm install node-red-contrib-azure-iot-edge-kpm

# Copy Node-RED project files into place
COPY settings.js /data/settings.js
COPY flows_cred.json /data/flows_cred.json
COPY flows.json /data/flows.json

EXPOSE 1880/tcp

# Start the container normally
CMD ["npm", "start"]
