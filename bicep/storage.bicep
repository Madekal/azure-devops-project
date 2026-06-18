// parameters
param storageLocation string = 'swedencentral'
param storageSku string = 'Standard_LRS'
param storageAccountName string = uniqueString(resourceGroup().id)


// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
    name: storageAccountName
    location: storageLocation
    sku: {
        name: storageSku
    }
    kind: 'StorageV2'
    properties: {
        accessTier: 'Hot'
    }
}
