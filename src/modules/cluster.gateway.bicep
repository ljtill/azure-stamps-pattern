// -------
// Imports
// -------

import * as types from '../types/default.bicep'

// ---------
// Providers
// ---------

provider 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

// ---------
// Resources
// ---------

// Gateway

#disable-next-line BCP081
resource gateway 'gateway.networking.k8s.io/Gateway@v1' = {
  metadata: {
    name: 'gateway'
    namespace: 'test-infra'
    annotations: {
      'alb.networking.azure.io/alb-id': albId
    }
  }
  spec: {
    gatewayClassName: 'azure-alb-external'
    listeners: [
      {
        name: 'http'
        port: 80
        protocol: 'HTTP'
        allowedRoutes: {
          namespaces: {
            from: 'Same'
          }
        }
      }
    ]
    addresses: [
      {
        type: 'alb.networking.azure.io/alb-frontend'
        value: 'default'
      }
    ]
  }
}

// HTTP Route

#disable-next-line BCP081
resource route 'gateway.networking.k8s.io/HTTPRoute@v1' = {
  metadata: {
    name: 'traffic-route'
    namespace: 'test-infra'
  }
  spec: {
    parentRefs: [
      {
        name: 'gateway'
      }
    ]
    rules: [
      {
        backendRefs: [
          {
            name: 'backend'
            port: 8080
            weight: 100
          }
        ]
      }
    ]
  }
}

// ---------
// Variables
// ---------

var defaults = loadJsonContent('../defaults.json')

var albId = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceNames.resourceGroup}/providers/Microsoft.ServiceNetworking/trafficControllers/${resourceNames.trafficController}'

var resourceNames = {
  resourceGroup: '${metadata.project}-rgn-${defaults.locations[metadata.location]}-rsg'
  trafficController: '${metadata.project}-rgn-${defaults.locations[metadata.location]}-tfc'
}

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string

param metadata types.metadata
