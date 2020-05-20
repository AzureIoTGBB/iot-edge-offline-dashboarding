#pull from the old publisher version
FROM mcr.microsoft.com/iotedge/opc-publisher:2.4.1

#probably don't need this
WORKDIR /appdata

COPY publishedNodes.json /appdata/publishedNodes.json

ENTRYPOINT ["dotnet", "/app/opcpublisher.dll"]