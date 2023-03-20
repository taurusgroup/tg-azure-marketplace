// DO NOT EDIT MANUALY - Terraform managed file
@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

// BEGIN - AKS params
@description('Specifies the name of the AKS cluster.')
param aksClusterName string = 'aks-${uniqueString(resourceGroup().id)}'

@description('Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Specifies the tags of the AKS cluster.')
param aksClusterTags object = {
  resourceType: 'AKS Cluster'
  createdBy: 'ARM Template'
}

@description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = 'azure'

@description('Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  'azure'
  'calico'
])
param aksClusterNetworkPolicy string = 'azure'

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = '10.244.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = '10.2.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '10.2.0.10'

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param aksClusterDockerBridgeCidr string = '172.17.0.1/16'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Paid'
  'Free'
])
param aksClusterSkuTier string = 'Paid'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.24.9'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies whether enabling AAD integration.')
param aadEnabled bool = false

@description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = false

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = false

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = false

@description('Specifies the unique name of the node pool profile in the context of the subscription and resource group.')
param nodePoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the node pool.')
param nodePoolVmSize string = 'Standard_D4s_v3'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in this master/agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param nodePoolOsDiskSizeGB int = 100

@description('Specifies the number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param nodePoolCount int = 1

@description('Specifies the OS type for the vms in the node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param nodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param nodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the node pool.')
param nodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the node pool.')
param nodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the node pool.')
param nodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param nodePoolScaleSetPriority string = 'Regular'

@description('Specifies the Agent pool node labels to be persisted across all nodes in agent pool.')
param nodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param nodePoolNodeTaints array = []

@description('Specifies the mode of an agent pool: System or User')
@allowed([
  'System'
  'User'
])
param nodePoolMode string = 'System'

@description('Specifies the type of a node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param nodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for nodes. Requirese the use of VirtualMachineScaleSets as node pool type.')
param nodePoolAvailabilityZones array = []

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = '${aksClusterName}-vnet'

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the default subnet hosting the AKS cluster.')
param aksSubnetName string = 'aks-subnet'

@description('Specifies the address prefix of the subnet hosting the AKS cluster.')
param aksSubnetAddressPrefix string = '10.0.0.0/16'
// END - AKS params

// BEGIN - SQL Server, DB params
@description('The name of the SQL logical server.')
param sqlServerName string = '${aksClusterName}-sql'

@description('The SQL server admin user name.')
param sqlServerAdminName string

@description('The password of the SQL server admin user.')
@secure()
param sqlServerAdminPassword string

@description('The name of the tg-validatord SQL Database.')
param sqlServerValidatordDbName string = 'tg-validatord'

@description('The name of the tg-capitald SQL Database.')
param sqlServerCapitaldDbName string = 'tg-capitald'
// END - SQL Server, DB params

// BEGIN - Taurus-PROTECT params
@description('The URI where the Taurus-PROTECT deployment script is.')
param tpUriScript string = 'https://taurusprotect.blob.core.windows.net/app/deploy.sh'
// END - Taurus-PROTECT params

module aks 'modules/aks.bicep' = {
  name: '${uniqueString(resourceGroup().id)}-aks'
  params: {
    location: location

    aadEnabled: aadEnabled
    aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    aadProfileEnableAzureRBAC: aadProfileEnableAzureRBAC
    aadProfileManaged: aadProfileManaged
    aadProfileTenantId: aadProfileTenantId
    aksClusterAdminUsername: aksClusterAdminUsername
    aksClusterDnsPrefix: aksClusterDnsPrefix
    aksClusterDnsServiceIP: aksClusterDnsServiceIP
    aksClusterDockerBridgeCidr: aksClusterDockerBridgeCidr
    aksClusterEnablePrivateCluster: aksClusterEnablePrivateCluster
    aksClusterKubernetesVersion: aksClusterKubernetesVersion
    aksClusterLoadBalancerSku: aksClusterLoadBalancerSku
    aksClusterName: aksClusterName
    aksClusterNetworkPlugin: aksClusterNetworkPlugin
    aksClusterNetworkPolicy: aksClusterNetworkPolicy
    aksClusterPodCidr: aksClusterPodCidr
    aksClusterServiceCidr: aksClusterServiceCidr
    aksClusterSkuTier: aksClusterSkuTier
    aksClusterSshPublicKey: aksClusterSshPublicKey
    aksClusterTags: aksClusterTags

    nodePoolAvailabilityZones: nodePoolAvailabilityZones
    nodePoolCount: nodePoolCount
    nodePoolEnableAutoScaling: nodePoolEnableAutoScaling
    nodePoolMaxCount: nodePoolMaxCount
    nodePoolMaxPods: nodePoolMaxPods
    nodePoolMinCount: nodePoolMinCount
    nodePoolMode: nodePoolMode
    nodePoolName: nodePoolName
    nodePoolNodeLabels: nodePoolNodeLabels
    nodePoolNodeTaints: nodePoolNodeTaints
    nodePoolOsDiskSizeGB: nodePoolOsDiskSizeGB
    nodePoolOsType: nodePoolOsType
    nodePoolScaleSetPriority: nodePoolScaleSetPriority
    nodePoolType: nodePoolType
    nodePoolVmSize: nodePoolVmSize

    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    aksSubnetName: aksSubnetName
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
  }
}

module sql 'modules/sql.bicep' = {
  name: '${uniqueString(resourceGroup().id)}-sql'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlServerAdminName: sqlServerAdminName
    sqlServerAdminPassword: sqlServerAdminPassword
    sqlServerValidatordDbName: sqlServerValidatordDbName
    sqlServerCapitaldDbName: sqlServerCapitaldDbName
    aksSubnetId: aks.outputs.aksSubnetId
  }
}

module deploy 'modules/deploy.bicep' = {
  name: '${uniqueString(resourceGroup().id)}-deploy'
  params: {
    location: location
    aksClusterName: aksClusterName
    tpUriScript: tpUriScript
    sqlServerFullyQualifiedDomainName: sql.outputs.sqlServerFullyQualifiedDomainName
    sqlServerAdminName: sqlServerAdminName
    sqlServerAdminPassword: sqlServerAdminPassword
    sqlServerValidatordDbName: sqlServerValidatordDbName
    sqlServerCapitaldDbName: sqlServerCapitaldDbName
  }
  dependsOn: [ aks, sql ]
}
