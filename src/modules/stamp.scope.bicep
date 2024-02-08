// -------
// Imports
// -------

import * as functions from '../functions/default.bicep'
import * as types from '../types/default.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource group 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: functions.getName(metadata.project, 'stamp', metadata.location, 'resourceGroup', stampId)
  location: metadata.location
  properties: {}
  tags: tags
}

// -------
// Modules
// -------

module resources './stamp.resources.bicep' = {
  scope: group
  params: {
    metadata: metadata
    tags: tags
    stampId: stampId
  }
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

output principalId string = resources.outputs.principalId
output subnetId string = resources.outputs.subnetId
