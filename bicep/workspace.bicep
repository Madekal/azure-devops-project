param workspaceName string = 'logworkspace'
param location string = 'swedencentral'
param storageAccountName string // 


// ================ LOG ANALYTICS WORKSPACE ======================

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {

    sku: {
      name: 'PerGB2018'
    }
    retentionInDays:30
    }
  }

// ======== DIAGNOSTIC SETTINGS =========================

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dsDevOps'
  scope: storageAccount
  properties: {
    workspaceId: workspace.id
    metrics:[ 
            {
        category: 'Transaction'
        enabled: true
            }
            ]
        }
      }

output workspaceId string = workspace.id
