targetScope = 'subscription'

param location string = 'westeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'poc-containerapps-dapr'
  location: location
}

param now string = utcNow()
module env 'environment.bicep' = {
  name: 'container-app-env-${take(guid(now), 5)}'
  scope: rg
  params: {
    environmentName: 'collegaues-apps'
    location: location
  }
}
