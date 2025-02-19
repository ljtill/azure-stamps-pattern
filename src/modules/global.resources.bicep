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

// Front Door

resource front 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: functions.getName(metadata.project, 'global', null, 'frontDoor', null)
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  tags: tags
}

// Origin Group

resource group 'Microsoft.Cdn/profiles/originGroups@2024-09-01' = {
  name: 'default'
  parent: front
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 2
    }
    healthProbeSettings: {
      probePath: '/'
      probeProtocol: 'Http'
      probeRequestType: 'HEAD'
      probeIntervalInSeconds: 100
    }
  }
}

resource origins 'Microsoft.Cdn/profiles/originGroups/origins@2024-09-01' = [
  for domain in metadata.domains!: {
    name: split(domain, '.')[0]
    parent: group
    properties: {
      hostName: domain
      httpPort: 80
      httpsPort: 443
      priority: 1
      weight: 1000
    }
  }
]

// Endpoints

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-09-01' = {
  name: 'default'
  parent: front
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-09-01' = {
  name: 'default'
  parent: endpoint
  properties: {
    enabledState: 'Enabled'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Disabled'
    forwardingProtocol: 'MatchRequest'
    supportedProtocols: [
      'Http'
    ]
    originGroup: {
      id: group.id
    }
    originPath: '/'
    patternsToMatch: [
      '/*'
    ]
  }
}

// ----------
// Parameters
// ----------

param metadata types.metadata
param tags object
