// -------
// Imports
// -------

import * as functions from '../functions/main.bicep'
import * as types from '../types/main.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource group 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: functions.getName(metadata.project, 'region', metadata.location, 'resourceGroup', null)
  location: metadata.location
  properties: {}
  tags: tags
}

// Role Assignments

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for i in range(0, metadata.stamps!): {
    name: guid('Reader', '${metadata.location}', '${i}')
    scope: subscription()
    properties: {
      principalId: stamps[i].outputs.principalId
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        'acdd72a7-3385-48ef-bd42-f606fba81ae7'
      )
      principalType: 'ServicePrincipal'
    }
  }
]

// -------
// Modules
// -------

// Stamps
// - Issue: Unable to implement 'optionalModuleNames'
// - Exception: Expected module syntax body to contain property 'name'
// - Patch: Added 'name' property to the module syntax body

module stamps './stamp.scope.bicep' = [
  for stampId in range(0, metadata.stamps!): {
    name: format('stamps-${stampId}-${uniqueString('stamps', deployment().name)}')
    scope: subscription()
    params: {
      metadata: metadata
      tags: tags
      stampId: padLeft(stampId, 3, '0')
    }
  }
]

// Resources

module resources './region.resources.bicep' = {
  scope: group
  params: {
    metadata: metadata
    tags: tags
    principalIds: [for i in range(0, metadata.stamps!): stamps[i].outputs.principalId]
    subnetIds: [for i in range(0, metadata.stamps!): stamps[i].outputs.subnetId]
  }
}

// ----------
// Parameters
// ----------

param metadata types.metadata
param tags object

// -------
// Outputs
// -------

output domain string = resources.outputs.domain
