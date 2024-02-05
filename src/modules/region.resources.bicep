// -------
// Imports
// -------

import * as types from '../types/default.bicep'

// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Role Assignment

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
  name: resourceName.trafficController
  location: metadata.location
  properties: {}
  tags: tags
}

// Frontends

resource frontend 'Microsoft.ServiceNetworking/trafficControllers/frontends@2023-11-01' = {
  name: 'default'
  parent: controller
  location: metadata.location
  properties: {}
}

// Associations

resource associations 'Microsoft.ServiceNetworking/trafficControllers/associations@2023-11-01' = {
  name: '${resourceName.association}-000'
  parent: controller
  location: metadata.location
  properties: {
    associationType: 'subnets'
    subnet: {
      id: subnetIds[0]
    }
  }
}

// - Issue: Multiple assocations are not supported by the Microsoft.ServiceNetworking RP at current.

// resource associations 'Microsoft.ServiceNetworking/trafficControllers/associations@2023-11-01' = [for (subnet, index) in subnetIds: {
//   name: '${resourceName.association}-${padLeft(index, 3, '0')}'
//   parent: controller
//   location: location
//   properties: {
//     associationType: 'subnets'
//     subnet: {
//       id: subnet
//     }
//   }
// }]

// ---------
// Variables
// ---------

var defaults = loadJsonContent('../defaults.json')

var resourceName = {
  trafficController: '${metadata.project}-rgn-${defaults.locations[metadata.location]}-tfc'
  association: '${metadata.project}-stp-${defaults.locations[metadata.location]}'
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
