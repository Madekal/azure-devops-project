param resourceName string = uniqueString(resourceGroup().id)
param location string = 'swedencentral'
param storageSku string = 'Standard_LRS'


// ======================= STORAGE ACCOUNT =====================
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: resourceName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
