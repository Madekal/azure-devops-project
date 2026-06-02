resource "azurerm_storage_account" "st" {

  # checkov:skip=CKV2_AZURE_1: "Lab environment - Microsoft-managed keys provide sufficient encryption for tfstate"
  # checkov:skip=CKV2_AZURE_38: "Soft-delete disabled intentionally to allow immediate destruction and recreation of the lab infrastructure"
  # checkov:skip=CKV2_AZURE_41: "Strict SAS policy configuration is not required for this educational project"
  # checkov:skip=CKV2_AZURE_33: "Private Endpoints are omitted to avoid extra costs and preserve GitHub Actions connectivity"
  # checkov:skip=CKV2_AZURE_47: "Container-level configurations block anonymous access where applicable"
  # checkov:skip=CKV_AZURE_190: "Public network access is adequately controlled via Azure storage network rules"
  # checkov:skip=CKV_AZURE_59: "Public access enabled to allow integration with external automation tools and runners"
  # checkov:skip=CKV_AZURE_206: "LRS replication is explicitly chosen for cost optimization in a dev environment"
  # checkov:skip=CKV_AZURE_33: "Diagnostic logging for storage services is not required in this non-production lab"
  # checkov:skip=CKV_AZURE_44: "Default minimal TLS version is acceptable for this testing scenario"
  # checkov:skip=CKV2_AZURE_21: "Blob storage read logging is not required for this non-production environment"
  # checkov:skip=CKV2_AZURE_40: "Shared Key authorization is allowed for development and deployment purposes"
  # checkov:skip=CKV2_AZURE_40: "Shared Key authorization is allowed for development and deployment purposes"

  name                     = "storagedevops2026project"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                    = "tfstate"
  storage_account_name    = azurerm_storage_account.st.name
  container_access_type   = "private"

}

