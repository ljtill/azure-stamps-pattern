// -------
// Imports
// -------

import * as types from '../types/default.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource group 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceName.resourceGroup
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

// ---------
// Variables
// ---------

var defaults = loadJsonContent('../defaults.json')

var resourceName = {
  resourceGroup: '${metadata.project}-stp-${defaults.locations[metadata.location]}-rsg-${stampId}'
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
