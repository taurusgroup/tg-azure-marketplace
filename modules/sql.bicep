@description('Specifies the location of SQL server.')
param location string = resourceGroup().location

@description('The name of the SQL logical server.')
param sqlServerName string

@description('The SQL server admin user name.')
param sqlServerAdminName string

@description('The password of the SQL server admin user.')
@secure()
param sqlServerAdminPassword string

@description('The name of the tg-validatord SQL Database.')
param sqlServerValidatordDbName string = 'tg-validatord'

@description('The name of the tg-capitald SQL Database.')
param sqlServerCapitaldDbName string = 'tg-capitald'

@description('Specifies the id of the default subnet hosting the AKS cluster nodes.')
param aksSubnetId string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdminName
    administratorLoginPassword: sqlServerAdminPassword
  }
}

resource sqlServerValidatordDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlServerValidatordDbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource sqlServerCapitaldDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlServerCapitaldDbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource sqlAksVnetRule 'Microsoft.Sql/servers/virtualNetworkRules@2022-05-01-preview' = {
  name: 'string'
  parent: sqlServer
  properties: {
    ignoreMissingVnetServiceEndpoint: true
    virtualNetworkSubnetId: aksSubnetId
  }
}

// For demo. Must be removed in the future.
// Container with tools needs to be created instead.
resource symbolicname 'Microsoft.Sql/servers/firewallRules@2022-08-01-preview' = {
  name: 'from_any'
  parent: sqlServer
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// Used by deploy.bicep module
output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
