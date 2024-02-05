// ------
// Usings
// ------

using 'main.bicep'

// ----------
// Parameters
// ----------

param project = ''

param metadata = [
  {
    location: 'uksouth'
    stamps: 1
  }
  {
    location: 'northeurope'
    stamps: 1
  }
  {
    location: 'eastus'
    stamps: 1
  }
  {
    location: 'australiaeast'
    stamps: 1
  }
]
