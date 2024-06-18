// -------
// Imports
// -------

import * as functions from '../functions/main.bicep'
import * as types from '../types/main.bicep'

// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Virtual Network

resource network 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: functions.getName(metadata.project, 'stamp', metadata.location, 'virtualNetwork', stampId)
  location: metadata.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.224.0.0/12'
      ]
    }
    subnets: [
      {
        name: 'aks-subnet'
        properties: {
          addressPrefix: '10.224.0.0/16'
        }
      }
      {
        name: 'alb-subnet'
        properties: {
          addressPrefix: '10.225.0.0/16'
          delegations: [
            {
              name: 'Microsoft.ServiceNetworking/trafficControllers'
              properties: {
                serviceName: 'Microsoft.ServiceNetworking/trafficControllers'
              }
            }
          ]
        }
      }
    ]
  }
  tags: tags
}

// Kubernetes Service

resource cluster 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: functions.getName(metadata.project, 'stamp', metadata.location, 'managedCluster', stampId)
  location: metadata.location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    nodeResourceGroup: functions.getName(metadata.project, 'stamp', metadata.location, 'nodeResourceGroup', stampId)
    dnsPrefix: functions.getName(metadata.project, 'stamp', metadata.location, 'managedCluster', stampId)
    agentPoolProfiles: [
      {
        name: 'system'
        count: 3
        vmSize: 'Standard_D2ds_v5'
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        osType: 'Linux'
        mode: 'System'
        availabilityZones: pickZones('Microsoft.ContainerService', 'managedClusters', metadata.location, 3)
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', network.name, 'aks-subnet')
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
      {
        name: 'user'
        count: 5
        vmSize: 'Standard_D2ds_v5'
        enableAutoScaling: true
        minCount: 3
        maxCount: 20
        osType: 'Linux'
        mode: 'User'
        availabilityZones: pickZones('Microsoft.ContainerService', 'managedClusters', metadata.location, 3)
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', network.name, 'aks-subnet')
      }
    ]
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    networkProfile: {
      networkPlugin: 'azure'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      imageCleaner: {
        enabled: true
        intervalHours: 168
      }
      workloadIdentity: {
        enabled: true
      }
    }
  }
  tags: tags
}

// Flux

resource extension 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = {
  name: 'flux'
  scope: cluster
  properties: {
    extensionType: 'microsoft.flux'
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    configurationSettings: {
      'source-controller.enabled': 'true'
      'helm-controller.enabled': 'true'
      'kustomize-controller.enabled': 'false'
      'notification-controller.enabled': 'true'
      'image-automation-controller.enabled': 'false'
      'image-reflector-controller.enabled': 'false'
    }
  }
}

// Managed Identity

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: functions.getName(metadata.project, 'stamp', metadata.location, 'userIdentity', stampId)
  location: metadata.location
  tags: tags
}

resource credential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview' = {
  name: 'default'
  parent: identity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: cluster.properties.oidcIssuerProfile.issuerURL
    subject: 'system:serviceaccount:azure-alb-system:alb-controller-sa'
  }
}

// Role Assignment

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(network.name, 'NetworkContributor')
  scope: network
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4d97b98b-1d4f-4787-a291-c67834d212e7'
    )
    principalType: 'ServicePrincipal'
  }
}

// -------
// Modules
// -------

// Kubernetes
// - Issue: Unable to implement 'optionalModuleNames'
// - Exception: Expected module syntax body to contain property 'name'
// - Patch: Added 'name' property to the module syntax body

module controller './cluster.controller.bicep' = {
  name: format('controller-${uniqueString('controller', deployment().name)}')
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
    clientId: identity.properties.clientId
  }
  dependsOn: [extension]
}

module application './cluster.application.bicep' = {
  name: format('application-${uniqueString('application', deployment().name)}')
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
  }
  dependsOn: [controller]
}

module gateway './cluster.gateway.bicep' = {
  name: format('gateway-${uniqueString('gateway', deployment().name)}')
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
    metadata: metadata
  }
  dependsOn: [
    application
    controller
  ]
}

// ----------
// Parameters
// ----------

param metadata types.metadata
param tags object

param stampId string

// -------
// Outputs
// -------

output principalId string = identity.properties.principalId
output subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', network.name, 'alb-subnet')
