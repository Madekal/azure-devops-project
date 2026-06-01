terraform {

   backend "azurerm" {
   use_azuread_auth = true
   resource_group_name = "rg-devops-project"
   storage_account_name = "storagedevops2026project"                              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
   container_name       = "tfstate"                               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
   key                  = "prod.terraform.tfstate"                # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
 }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
  
}

 provider "azurerm" {
    features {}
    
   }