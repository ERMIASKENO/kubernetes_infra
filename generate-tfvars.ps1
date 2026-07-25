Write-Host "=== Interactive tfvars Generator ===" -ForegroundColor Cyan

function Ask($msg) {
    Write-Host $msg -ForegroundColor Yellow
    Read-Host
}

$rgName     = Ask "Resource Group Name:"
$location   = Ask "Azure Location (e.g., westeurope):"
$prefix     = Ask "Prefix (e.g., ecom-prod):"

$vnet       = Ask "VNet CIDR (e.g., 10.0.0.0/16):"
$k8sSubnet  = Ask "Kubernetes Subnet CIDR (e.g., 10.0.1.0/24):"
$bastion    = Ask "Bastion Subnet CIDR (e.g., 10.0.10.0/27):"
$peSubnet   = Ask "Private Endpoints Subnet CIDR (e.g., 10.0.20.0/27):"

$adminIP    = Ask "Your public IP (for NSG) (e.g., 1.2.3.4/32):"
$adminUser  = Ask "Admin username:"
$sshKey     = Ask "SSH public key path (e.g., ~/.ssh/id_rsa.pub):"

$cpSize     = Ask "Control Plane VM Size (e.g., Standard_D4s_v5):"
$workerSize = Ask "Worker VM Size (e.g., Standard_D4s_v5):"
$workerCnt  = Ask "Worker Count (e.g., 2):"

$acrName    = Ask "ACR Name:"
$kvName     = Ask "Key Vault Name:"
$tenantId   = Ask "Tenant ID:"
$objectId   = Ask "Admin Object ID (Azure AD):"

$dbPass     = Ask "Database Password:"
$joinCmd    = Ask "kubeadm join command (paste full command):"

$tags = Ask "Tags (key=value,key=value):"

# Convert tags to HCL map
$tagMap = $tags -split "," | ForEach-Object {
    $kv = $_ -split "="
    "  ${kv[0]} = \"${kv[1]}\""
} | Out-String

$tfvars = @"
resource_group_name = "$rgName"
location            = "$location"

prefix = "$prefix"

vnet_cidr                 = "$vnet"
k8s_subnet_cidr           = "$k8sSubnet"
bastion_subnet_cidr       = "$bastion"
private_endpoints_subnet_cidr = "$peSubnet"
admin_allowed_cidr        = "$adminIP"

admin_username       = "$adminUser"
admin_ssh_public_key = file("$sshKey")

control_plane_vm_size = "$cpSize"
worker_vm_size        = "$workerSize"
worker_count          = $workerCnt

acr_name        = "$acrName"
key_vault_name  = "$kvName"
tenant_id       = "$tenantId"
admin_object_id = "$objectId"

example_db_password   = "$dbPass"
kubeadm_join_command  = "$joinCmd"

tags = {
$tagMap
}
"@

$path = "terraform/envs/prod.tfvars"
$tfvars | Out-File $path

Write-Host "`nprod.tfvars generated at: $path" -ForegroundColor Green
