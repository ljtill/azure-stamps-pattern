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

module resources './global.resources.bicep' = {
  scope: group
  params: {
    metadata: metadata
    tags: tags
  }
}

// ---------
// Variables
// ---------

var defaults = loadJsonContent('../defaults.json')

var resourceName = {
  resourceGroup: '${metadata.project}-glb-rsg'
}

// ----------
// Parameters
// ----------

param metadata types.metadata
param tags object
