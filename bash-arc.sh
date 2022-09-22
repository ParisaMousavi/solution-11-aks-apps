#!/bin/sh

# <--- Change the following environment variables according to your Azure service principal name --->

echo "Exporting environment variables"
# export appId='<Your Azure service principal name>'
# export password='<Your Azure service principal password>'
# export tenantId='<Your Azure tenant ID>'
# export resourceGroup='<Azure resource group name>'
# export arcClusterName='<The name of your k8s cluster as it will be shown in Azure Arc>'

resourceGroup=$1
arcClusterName=$2

# Log in to Azure
echo "Log in to Azure with Service Principle"
# az login --service-principal --username $appId --password $password --tenant $tenantId

# Registering Azure Arc providers
echo "Registering Azure Arc providers"
az provider register --namespace Microsoft.Kubernetes --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
az provider register --namespace Microsoft.ExtendedLocation --wait

az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

# Getting AKS credentials  projn-aks-app-dev-gwc projn-rg-app-dev-gwc
echo "Getting AKS credentials (kubeconfig)"
az aks get-credentials --name $arcClusterName --resource-group $resourceGroup --overwrite-existing

echo "Clear cached helm Azure Arc Helm Charts"
rm -rf ~/.azure/AzureArcCharts

# Installing Azure Arc k8s CLI extensions
echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""

echo "Connecting the cluster to Azure Arc"
az connectedk8s connect --name $arcClusterName --resource-group $resourceGroup --location 'westeurope' --tags 'Project=jumpstart_azure_arc_k8s' --correlation-id "c18ab9d0-685e-48e7-ab55-12588447b0ed"
# az connectedk8s connect --name projn-aks-app-dev-gwc --resource-group add-aks-to-arc --location westeurope --correlation-id c18ab9d0-685e-48e7-ab55-12588447b0ed --tags Datacenter=Azure Germany West Center City=Azure Germany West Center    
# az connectedk8s connect --name $arcClusterName --resource-group $resourceGroup --location 'westeurope' 
# az connectedk8s list --resource-group $resourceGroup --output table