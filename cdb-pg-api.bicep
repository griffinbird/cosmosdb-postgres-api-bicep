param clusterName string
param location string = resourceGroup().location

param administratorLogin string = 'citus'
@secure()
param administratorLoginPassword string

param enablePublicIpAccess bool = true
param enableHa bool = false

param postgresqlVersion string = '14'

// Coordinator settings
var coordinatorCount = 1
var coordinatorVcores = 2
var coordinatorStorageSizeMB = 131072

// Worker settings
var workerCount = 0
var workerVcores = 4
var workerStorageSizeMB = 524288

// Firewall settings
var firewallRules = {
  example: {
    start: '123.123.123.0'
    end: '123.123.123.10'
  }
}

resource serverGroup 'Microsoft.DBforPostgreSQL/serverGroupsv2@2020-10-05-privatepreview' = {
  name: clusterName
  location: location
  kind: 'CosmosDBForPostgreSQL'
  properties: {
    createMode: 'Default'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    backupRetentionDays: 35
    enableMx: false
    enableZfs: false
    previewFeatures: true
    postgresqlVersion: postgresqlVersion
    serverRoleGroups: [
      {
        name: ''
        role: 'Coordinator'
        serverCount: coordinatorCount
        serverEdition: 'GeneralPurpose'
        vCores: coordinatorVcores
        storageQuotaInMb: coordinatorStorageSizeMB
        enableHa: enableHa
        enablePublicIpAccess: enablePublicIpAccess
      }
      {
        name: ''
        role: 'Worker'
        serverCount: workerCount
        serverEdition: 'MemoryOptimized'
        vCores: workerVcores
        storageQuotaInMb: workerStorageSizeMB
        enableHa: enableHa
        enablePublicIpAccess: enablePublicIpAccess
      }
    ]
  }
}

@batchSize(1)
resource serverFirewallRules 'Microsoft.DBforPostgreSQL/serverGroupsv2/firewallRules@2020-10-05-privatepreview' = [for rule in items(firewallRules): {
  name: '${serverGroup.name}/${rule.key}'
  properties: {
    startIpAddress: rule.value.start
    endIpAddress: rule.value.end
  }
}]
