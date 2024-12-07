# Azure Management

## Introduction

In this project, we will leverage Application Insights to monitor and manage the health and performance of Virtual Machine Scale Sets (VMSS) and Azure Kubernetes Service (AKS). Application Insights will enable us to track critical metrics, identify anomalies, and gain insights into the operational status of our resources.

Additionally, we will integrate Azure Alerts to proactively notify us about issues or threshold breaches, These alerts will trigger executing Azure Runbooks, to implement self-healing mechanisms. 

## Set up

In this project, we will use github action flow and Terraform to build the infratructure and deploy the applicatiuon automatically, to use the workflow, you should set up all the secret and variables below:

  - The app registration should have the Contributor role, and GitHub federated access should be set up for the repository repo:wanghongran2023/Azure_AKS_VMSS_Management:environment:Production and repo:wanghongran2023/Azure_AKS_VMSS_Management:ref:refs/heads/main. 

| Secret Name | Content |
|----------|----------|
| 1. TENANT_ID 			| Microsoft Entra ID -> Tenant ID |
| 2. SUBSCRIPTION_ID		| Subscriptions -> Subscriptions ID |
| 3. SP_CLIENT_ID		| Application -> Application (client) ID |
| 4. SP_CLIENT_SECRET	        | Application Secret -> Value |

| Variables Name | Content |
|----------|----------|
| 4. RESOURCE_GROUP_LOCATION	| Location for resource group, like west US |
| 5. RESOURCE_GROUP_NAME	| Name for resource group |

## Deploy Infra and APp

  - Run the github Workflow. This workflow will use GitHub secrets and variables to update Terraform variables and deploy the Vmss, bastion, resource group, aks ... to Azure
