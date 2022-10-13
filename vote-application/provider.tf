terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "solution-11-vote-website"
    key                  = "terraform.tfstate"
  }

}

provider "kubernetes" {
  config_path    = "./config"
}