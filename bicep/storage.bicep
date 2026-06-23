param location string = 'swedencentral'
param storageSku string = 'Standard_LRS'
param storageAccountName string = 'strg2026azprojectdevops'

// ======================= STORAGE ACCOUNT =====================
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
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
