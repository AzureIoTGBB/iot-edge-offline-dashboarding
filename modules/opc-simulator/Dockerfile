# Start with upstream node-red
FROM gbbiotwesouth/noderededgemodule:0.12.0

WORKDIR /node-red
# Copy package.json to the WORKDIR so npm builds all
# of your added modules for Node-RED
COPY package.json .
RUN npm install --only=production

# Copy Node-RED project files into place
COPY settings.js ./settings.js
COPY flows_cred.json ./flows_cred.json
COPY flows.json ./flows.json
COPY config.json ./config.json

EXPOSE 1880/tcp

# is this necessary? USER node

# Start the container normally
CMD ["npm", "start"]

# Start the container with node red
# CMD ["node-red", "--flowFile", "flows.json", "--userDir", "/node-red/"]
