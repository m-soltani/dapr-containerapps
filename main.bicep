targetScope = 'subscription'

param location string = 'westeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'poc-containerapps-dapr'
  location: location
}

param now string = utcNow()


module vnet 'vnets.bicep' = {
  scope: rg
  name: 'vnet-${take(guid(now), 5)}'
  params: {
    name: 'vnet-aca'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'PrivateEndpoints'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PublicSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'InfrastructureSubnet'
        properties: {
          addressPrefix: '10.0.2.0/23'
        }
      }
      {
        name: 'RuntimeSubnet'
        properties: {
          addressPrefix: '10.0.4.0/23'
        }
      }
    ]
  }
}


module env 'environment.bicep' = {
  name: 'container-app-env-${take(guid(now), 5)}'
  scope: rg
  params: {
    environmentName: 'collegaues-apps'
    location: location
    infrastructureSubnetId: filter(vnet.outputs.vnetSubnets, arg => arg.name == 'InfrastructureSubnet')[0].id
    runtimeSubnetId: filter(vnet.outputs.vnetSubnets, arg => arg.name == 'RuntimeSubnet')[0].id
  }
}
