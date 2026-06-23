targetScope = 'resourceGroup'

module storageModule './storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: 'swedencentral'
  }
}


module workspaceModule './workspace.bicep' = {
  name: 'workspaceDeployment'
  params: {
    location: 'swedencentral'
    storageAccountName: storageModule.outputs.storageAccountName 
  }
}
