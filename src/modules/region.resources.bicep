// -------
// Imports
// -------

import * as functions from '../functions/default.bicep'
import * as types from '../types/default.bicep'

// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Role Assignments

resource assignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (principalId, index) in principalIds: {
  name: guid(principalId, 'ApplicationGatewayForContainersConfigurationManager', '${index}')
  scope: controller
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fbc52c3f-28ad-4303-a892-8a056630b8f1')
    principalType: 'ServicePrincipal'
  }
}]

// Traffic Controller (AGC)

resource controller 'Microsoft.ServiceNetworking/trafficControllers@2023-11-01' = {
  name: functions.getName(metadata.project, 'region', metadata.location, 'trafficController', null)
  location: metadata.location
  properties: {}
  tags: tags
}

// Frontend

resource frontend 'Microsoft.ServiceNetworking/trafficControllers/frontends@2023-11-01' = {
  name: functions.getName(metadata.project, 'region', metadata.location, 'frontend', null)
  parent: controller
  location: metadata.location
  properties: {}
}

// Associations
// - Issue: Multiple assocations are not supported by the Microsoft.ServiceNetworking RP.

resource associations 'Microsoft.ServiceNetworking/trafficControllers/associations@2023-11-01' = {
  name: functions.getName(metadata.project, 'stamp', metadata.location, 'assocation', null)
  parent: controller
  location: metadata.location
  properties: {
    associationType: 'subnets'
    subnet: {
      id: subnetIds[0]
    }
  }
}

// ----------
// Parameters
// ----------

param metadata types.metadata
param tags object

param principalIds array
param subnetIds array

// -------
// Outputs
// -------

output domain string = frontend.properties.fqdn
