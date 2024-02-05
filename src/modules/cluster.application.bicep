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

// Namespace

resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: 'test-infra'
  }
}

// Service

resource service 'core/Service@v1' = {
  metadata: {
    name: 'backend'
    namespace: 'test-infra'
  }
  spec: {
    selector: {
      app: 'backend'
    }
    ports: [
      {
        name: 'http'
        protocol: 'TCP'
        port: 8080
        targetPort: 3000
      }
    ]
  }
  dependsOn: [ namespace ]
}

// Deployment

resource deployment 'apps/Deployment@v1' = {
  metadata: {
    name: 'backend'
    namespace: 'test-infra'
    labels: {
      app: 'backend'
    }
  }
  spec: {
    replicas: 3
    selector: {
      matchLabels: {
        app: 'backend'
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'backend'
        }
      }
      spec: {
        containers: [
          {
            name: 'backend'
            image: 'gcr.io/k8s-staging-ingressconformance/echoserver:v20221109-7ee2f3e'
            env: [
              {
                name: 'POD_NAME'
                value: 'backend'
              }
              {
                name: 'NAMESPACE'
                value: 'test-infra'
              }
            ]
          }
        ]
      }
    }
  }
  dependsOn: [ namespace ]
}

// ---------
// Variables
// ---------

var defaults = loadJsonContent('../defaults.json')

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
