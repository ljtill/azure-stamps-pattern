// -------
// Imports
// -------

import * as functions from '../functions/main.bicep'
import * as types from '../types/main.bicep'

// ---------
// Providers
// ---------

provider kubernetes with {
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
        value: frontendName
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

var albId = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroupName}/providers/Microsoft.ServiceNetworking/trafficControllers/${trafficControllerName}'

var resourceGroupName = functions.getName(metadata.project, 'region', metadata.location, 'resourceGroup', null)
var trafficControllerName = functions.getName(metadata.project, 'region', metadata.location, 'trafficController', null)
var frontendName = functions.getName(metadata.project, 'region', metadata.location, 'frontend', null)

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string

param metadata types.metadata
