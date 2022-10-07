data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "enterprise-aks"
    key                  = "terraform.tfstate"
  }
}
