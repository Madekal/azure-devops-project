# Azure Infrastructure Deployment with Terraform & GitHub Actions

This repository contains a fully automated, production-ready Infrastructure as Code (IaC) project that deploys a secure network and compute environment in Microsoft Azure using *Terraform* and *GitHub Actions* for CI/CD. It's a small project that helps me learn and understand terraform. The project will be developed on an ongoing basis. In future I'm planning to add a Docker app, a firewall, and expand whole infrastructure in every direction. Every abbreviation for Azure resources I used is from official Microsoft Documentation (links at the bottom). I tried to minimize the use of AI - only for deployment errors, and more complicated resource connection between them. In this project I'm using the Service Principal, because of my Azure Student account limits - lack of tenant administrative privileges - (I can't use Microsoft Entra ID therefore OIDC won't work).

## Features
- **Automated Security:** Secure, random VM administrator password generation using the `random` provider.
- **Remote Backend:** Terraform state (`.tfstate`) is securely stored in an Azure Blob Storage container with state locking support.
- **Automated CI/CD Pipeline:** Fully configured GitHub Actions workflow that automatically initializes, validates, and plans infrastructure changes upon push.

## Project Structure

```

├── .github/
│   └── workflows/
│       └── terraform.yaml     # GitHub Actions CI/CD workflow pipeline
├── modules/
│   ├── compute/
│   │   ├── main.tf            # Virtual Machines and Load Balancer configuration
│   │   └── variables.tf       # Compute module variables
│   ├── network/
│   │   ├── main.tf            # VNet, Subnets, and Network security components
│   │   ├── variables.tf       # Network module variables
│   │   └── outputs.tf         # Outputs
│   ├── monitoring/
│   │   ├── main.tf            # Log Analytics and diagnostic settings
│   │   ├── variables.tf       # Monitoring variables
│   │   └── outputs.tf         # Outputs
│   └── storage/
│       ├── main.tf            # Storage and container
│       └── variables.tf       # Storage variables
├── main.tf                    # Root configuration calling the modules
├── providers.tf               # AzureRM and Random provider configurations
├── variables.tf               # Root input variables
└── README.md                  # Project documentation

```

## Prerequisites

- **Active Azure account**
- **Prepared account storage for tf.state**
- **Installed Terraform and Azure CLI for code testing**


## GitHub Secret Configuration

- **ARM Secrets** - in this project I used ARM Secret for Subscription ID, Client ID, Client Secret and Tenant ID

- **Required roles and used commands** 

    The Service Principal require both Contributor Role for your subscription, and Storage Blob Owner for your storage account to work properly 
    

    `az account show --query "{SubscriptionID:id, TenantID:tenantId}"` --output table - To get your current Subscription and Client ID

    `az ad sp create-for-rbac --name "github-actions-terraform" --role Contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> --json-auth ` - To give Service Principal Contributor role, and get your Tenant ID / Client Secret

    `az role assignment create --assignee "YOUR-CLIENT-ID" --role "Storage Blob Data Owner" --scope "/subscriptions/YOUR-AZURE-SUBSCRIPTION-ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT_NAME" ` - To give Service Principal Storage Blob Data owner for your storage account

- **Secrets Structure**

    AZURE_SUBSCRIPTION_ID - your Subscription ID
    AZURE_CLIENT_ID       - your Client ID
    AZURE_TENANT_ID       - your Tenant ID
    AZURE_CLIENT_SECRET   - your Client Secret


## Local Development

To test and run this project locally, execute the following commands in your terminal:

1. Log in to Azure:
`az login`

2. Initialize Terraform and connect to remote state:
`terraform init`

3. Preview changes:
`terraform plan`

4. Apply changes:
`terraform apply`


## References

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
https://developer.hashicorp.com/terraform/language
https://github.com/Azure/terraform/tree/master/quickstart
https://learn.microsoft.com/en-us/azure/architecture/guide/
https://www.checkov.io/2.Basics/Installing%20Checkov.html