// -------
// Imports
// -------

import * as types from './types/main.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

// Regions
// - Issue: Unable to implement 'optionalModuleNames'
// - Exception: Expected module syntax body to contain property 'name'
// - Patch: Added 'name' property to the module syntax body

module regions './modules/region.scope.bicep' = [
  for (metadata, index) in metadata: {
    name: format('regions-${index}-${uniqueString('regions', deployment().name)}')
    scope: subscription()
    params: {
      metadata: metadata
      tags: {}
    }
  }
]

// Global

module global './modules/global.scope.bicep' = {
  scope: subscription()
  params: {
    metadata: {
      project: metadata[0].project
      location: 'westus2'
      domains: [for (metadata, index) in metadata: regions[index].outputs.domain]
    }
    tags: {}
  }
}

// ----------
// Parameters
// ----------

param metadata types.metadata[]
