@description('Specifies the location of SQL server.')
param location string

@description('Specifies the name of the AKS cluster.')
param aksClusterName string

@description('The URI where the Taurus-PROTECT deployment script is.')
param tpUriScript string

@description('The SQl server FQDN')
param sqlServerFullyQualifiedDomainName string

@description('The SQL server admin user name.')
param sqlServerAdminName string

@description('The password of the SQL server admin user.')
@secure()
param sqlServerAdminPassword string

@description('The name of the tg-validatord SQL Database.')
param sqlServerValidatordDbName string

@description('The name of the tg-capitald SQL Database.')
param sqlServerCapitaldDbName string

resource deployManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${aksClusterName}-uai'
  location: location
}

resource deployIdentityRoleAssign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: deployManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deployScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${aksClusterName}-ds'
  location: location
  dependsOn: [
    deployIdentityRoleAssign
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deployManagedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT30M'
    primaryScriptUri: tpUriScript
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'RESOURCEGROUP'
        value: resourceGroup().name
      }
      {
        name: 'CLUSTER_NAME'
        value: aksClusterName
      }
      {
        name: 'SQL_SERVER_FQDN'
        value: sqlServerFullyQualifiedDomainName
      }
      {
        name: 'SQL_SERVER_ADMIN_NAME'
        value: sqlServerAdminName
      }
      {
        name: 'SQL_SERVER_ADMIN_PASSWORD'
        secureValue: sqlServerAdminPassword
      }
      {
        name: 'SQL_SERVER_VALIDATORD_DB_NAME'
        value: sqlServerValidatordDbName
      }
      {
        name: 'SQL_SERVER_CAPITALD_DB_NAME'
        value: sqlServerCapitaldDbName
      }
    ]
  }
}
