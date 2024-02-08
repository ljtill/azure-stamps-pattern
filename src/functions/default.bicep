// ---------
// Functions
// ---------

// Deployment Scopes

func deploymentScopeAlias(scope string) string => '-${loadJsonContent('../defaults.json').deploymentScopes[scope]}'

// Locations

func locationAlias(location string) string => '-${loadJsonContent('../defaults.json').locations[location]}'

// Resource Types

func resourceTypeAlias(resourceType string) string => '-${loadJsonContent('../defaults.json').resourceTypes[resourceType]}'

// Names
// See defaults.json for allowed values

@export()
func getName(project string, deploymentScope string, location string?, resourceType string, count string?) string => '${project}${deploymentScopeAlias(deploymentScope)}${location == null ? '' : locationAlias(location!)}${resourceTypeAlias(resourceType)}${count == null ? '' : '-${count!}'}'
