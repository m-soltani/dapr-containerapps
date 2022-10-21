@description('''
  Mandatory: Name of the virtual network resource. See:
  https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks
''')
param name string

@description('Resource location')
param location string = resourceGroup().location

@description('Tags for the virtual network gateway')
param tags object = {}

@description('Mandatory: Array of IP address ranges that can be used by subnets.')
param addressPrefixes array = []

@description('Optional: Bgp Communities sent over ExpressRoute with each route corresponding to a prefix in this VNET.')
param bgpCommunities object = {}

@description('Optional: The DDoS protection plan associated with the virtual network.')
param ddosProtectionPlan object = {}

@description('Optional: The dhcpOptions that contains an array of DNS servers available to VMs deployed in the virtual network.')
param dhcpOptions object = {}

@description('''
  Optional: Indicates if DDoS protection is enabled for all the protected resources in the virtual network.
  It requires a DDoS protection plan associated with the resource.
''')
param enableDdosProtection bool = false

@description('Optional: Indicates if VM protection is enabled for all the subnets in the virtual network.')
param enableVmProtection bool = false

@description('Optional: Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet.')
param encryption object = {}

@description('Optional: The FlowTimeout value (in minutes) for the Virtual Network')
param flowTimeoutInMinutes int = 0

@description('Optional: Array of IpAllocation which reference this VNET.')
param ipAllocations array = []

@description('Subnets to deploy see network_subnets.jsonc')
param subnets array = []

@description('Peering configuration see network_peerings.jsonc')
param virtualNetworkPeerings array = []

@description('''
  Options for diagnostic settings. See:
  https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep
''')
param diagProperties object = {}

@description('''
  Array of options for for role assignments for the vnet. See:
  https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-arm-template
''')
param roleAssignments array = []

resource virtualNetworks_resource 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name:       name
  tags:       empty(tags) ? null : tags
  location:   location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    bgpCommunities:         empty(bgpCommunities) ? null : bgpCommunities
    ddosProtectionPlan:     empty(ddosProtectionPlan) ? null : ddosProtectionPlan
    dhcpOptions:            empty(dhcpOptions) ? null : dhcpOptions
    enableDdosProtection:   enableDdosProtection ? true : null
    enableVmProtection:     enableVmProtection ? true : null
    encryption:             empty(encryption) ? null : encryption
    flowTimeoutInMinutes:   flowTimeoutInMinutes == 0 ? null : flowTimeoutInMinutes
    ipAllocations:          empty(ipAllocations) ? null : ipAllocations
    subnets:                empty(subnets) ? null : subnets
    virtualNetworkPeerings: empty(virtualNetworkPeerings) ? null : virtualNetworkPeerings
  }
}

resource diagnosticSettings_resource 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagProperties)) {
  scope:      virtualNetworks_resource
  name:       '${name}-diag'
  properties: diagProperties
}

resource roleAssignment_resource 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for ra in roleAssignments : if (!empty(roleAssignments)) {
  scope:  virtualNetworks_resource
  name:   guid(name, ra.principalId, ra.roleDefinitionId)
  properties: {
    condition:                          contains(ra, 'condition') ? ra.condition : null
    conditionVersion:                   contains(ra, 'conditionVersion') ? ra.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(ra, 'delegatedManagedIdentityResourceId') ? ra.delegatedManagedIdentityResourceId : null
    description:                        contains(ra, 'description') ? ra.description : null
    principalId:                        contains(ra, 'principalId') ? ra.principalId : null
    principalType:                      contains(ra, 'principalType') ? ra.principalType : null
    roleDefinitionId:                   contains(ra, 'roleDefinitionId') ? ra.roleDefinitionId : null
  }
}]

output virtualNetwork object = {
  name:       virtualNetworks_resource.name
  resourceId: virtualNetworks_resource.id
}

output vnetSubnets array = virtualNetworks_resource.properties.subnets
