# Traffic Routing

Discover the implementation of Deployment Stamp patterns in Microsoft Azure with Bicep through this repository, showcasing best practices for ensuring the resilience and high availability of applications.

Leveraging essential Azure resources like Front Door, Application Gateway for Containers, Kubernetes Service, and Availability Zones, this example illustrates the establishment of a robust architecture. Notably, it highlights the seamless traffic distribution capabilities across global clusters enabled by the integration of Front Door, Application Gateway for Containers, and Kubernetes. Explore a highly available and scalable infrastructure designed for efficient traffic routing and optimal performance. 🌐🚀

![Architecture](./eng/images/architecture.png)

---

## Repository Structure

Within the `src/` directory, you'll find the following artifacts:

- `main.bicep`: This Bicep file loads defaults, user-defined settings, and resource modules.
- `main.bicepparam`: Bicep parameter file handling environment-specific settings.
- `bicepconfig.json`: JSON file customizing the Bicep development experience.
- `defaults.json`: JSON file providing Bicep with a set of reusable common values.
- `modules/`: Contains resource groups and resource modules to quickly get started.

The global files handle the deployment of Azure Front Door and configure traffic routing policies.

- `modules/global.scope.bicep`: Handles the global deployment at the subscription scope, such as Resource Group creation and Role Assignments.
- `modules/global.resources.bicep`: Handles the creation of Azure Resources, such as Front Door.

The region files deploy Application Gateways for Containers as a regional service, distributing traffic across stamps.

- `modules/region.scope.bicep`: Handles the global deployment at the subscription scope, such as Resource Group creation and Role Assignments.
- `modules/region.resources.bicep`: Handles the creation of Azure Resources, such as Application Gateway for Containers.

The stamp files deploy Kubernetes clusters along with Virtual Networks and Managed Identity. Stamps are isolated compute units without east-west connectivity options.

- `modules/stamp.scope.bicep`: Handles the global deployment at the Resource Group scope.
- `modules/stamp.resources.bicep`: Handles the creation of Azure Resources, such as Kubernetes.

The application files configure the Kubernetes control plane, deploying the controller for Application Gateway for Containers, along with a sample application on the cluster.

- `modules/cluster.application.bicep`: Handles the creation of an example Kubernetes application deployment.
- `modules/cluster.controller.bicep`: Handles the creation of the Application Gateway for Containers on Kubernetes controller.
- `modules/cluster.gateway.bicep`: Handles the creation of the Gateway API resources for Application Gateway for Containers.

Within the `eng/` directory, find the following artifacts:

- `images/`: Contains images for the README.md file.
- `scripts/`: Contains deployment stack creation and deletion scripts.


---

## Getting Started

### Deployment

```bash
./eng/scripts/create.sh
```

```bash
./eng/scripts/delete.sh
```

---

### Links

- [Bicep](https://github.com/Azure/bicep)
- [Templates](https://docs.microsoft.com/azure/templates)
