Write-Host "=== Terraform Azure Infrastructure Prerequisite Checker ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# Helper function
# ------------------------------------------------------------
function Check-Step {
    param(
        [string]$Message,
        [bool]$Condition
    )
    if ($Condition) {
        Write-Host "[PASS] $Message" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $Message" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 1. Check Azure CLI
# ------------------------------------------------------------
Write-Host "`nChecking Azure CLI..."
$az = Get-Command az -ErrorAction SilentlyContinue
Check-Step "Azure CLI installed" ($az -ne $null)

if ($az -eq $null) {
    Write-Host "Install Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit
}

# ------------------------------------------------------------
# 2. Check Azure login
# ------------------------------------------------------------
Write-Host "`nChecking Azure login..."
try {
    $account = az account show --query id -o tsv 2>$null
    Check-Step "Logged into Azure" ($account -ne "")
} catch {
    Check-Step "Logged into Azure" $false
    Write-Host "Run: az login"
    exit
}

# ------------------------------------------------------------
# 3. Check subscription
# ------------------------------------------------------------
Write-Host "`nChecking subscription..."
$subName = az account show --query name -o tsv
Check-Step "Active subscription selected: $subName" ($subName -ne "")

# ------------------------------------------------------------
# 4. Check required Azure providers
# ------------------------------------------------------------
Write-Host "`nChecking Azure resource providers..."

$providers = @(
    "Microsoft.Network",
    "Microsoft.Compute",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry",
    "Microsoft.Insights"
)

foreach ($p in $providers) {
    $state = az provider show --namespace $p --query registrationState -o tsv
    Check-Step "$p registered" ($state -eq "Registered")
}

Write-Host "If any provider is FAIL, run:" -ForegroundColor Yellow
Write-Host "az provider register --namespace <ProviderName>" -ForegroundColor Yellow

# ------------------------------------------------------------
# 5. Check SSH keys
# ------------------------------------------------------------
Write-Host "`nChecking SSH keys..."

$sshPub = "$HOME/.ssh/id_rsa.pub"
$sshPriv = "$HOME/.ssh/id_rsa"

Check-Step "SSH public key exists ($sshPub)" (Test-Path $sshPub)
Check-Step "SSH private key exists ($sshPriv)" (Test-Path $sshPriv)

if (-not (Test-Path $sshPub)) {
    Write-Host "Generate SSH key: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa"
}

# ------------------------------------------------------------
# 6. Check your public IP
# ------------------------------------------------------------
Write-Host "`nChecking public IP..."
try {
    $myIP = (Invoke-WebRequest -Uri "https://ifconfig.me/ip" -UseBasicParsing).Content.Trim()
    Check-Step "Public IP retrieved: $myIP" ($myIP -ne "")
} catch {
    Check-Step "Public IP retrieved" $false
}

# ------------------------------------------------------------
# 7. Check Azure AD Object ID
# ------------------------------------------------------------
Write-Host "`nChecking Azure AD Object ID..."

try {
    $userUPN = az account show --query user.name -o tsv
    $objectId = az ad user show --id $userUPN --query objectId -o tsv
    Check-Step "Azure AD Object ID found: $objectId" ($objectId -ne "")
} catch {
    Check-Step "Azure AD Object ID found" $false
    Write-Host "Run: az ad user show --id <your-email>"
}

# ------------------------------------------------------------
# 8. Check Terraform installation
# ------------------------------------------------------------
Write-Host "`nChecking Terraform..."
$tf = Get-Command terraform -ErrorAction SilentlyContinue
Check-Step "Terraform installed" ($tf -ne $null)

if ($tf -eq $null) {
    Write-Host "Install Terraform: https://developer.hashicorp.com/terraform/downloads"
}

# ------------------------------------------------------------
# 9. Check prod.tfvars completeness
# ------------------------------------------------------------
Write-Host "`nChecking prod.tfvars..."

$tfvarsPath = "$root/envs/prod.tfvars"

if (Test-Path $tfvarsPath) {
    $content = Get-Content $tfvarsPath -Raw

    $requiredVars = @(
        "resource_group_name",
        "location",
        "vnet_cidr",
        "k8s_subnet_cidr",
        "bastion_subnet_cidr",
        "private_endpoints_subnet_cidr",
        "admin_allowed_cidr",
        "admin_username",
        "admin_ssh_public_key",
        "control_plane_vm_size",
        "worker_vm_size",
        "worker_count",
        "acr_name",
        "key_vault_name",
        "tenant_id",
        "admin_object_id",
        "example_db_password"
    )

    foreach ($var in $requiredVars) {
        Check-Step "$var present in prod.tfvars" ($content -match $var)
    }
} else {
    Check-Step "prod.tfvars exists" $false
    Write-Host "Expected at: terraform/envs/prod.tfvars"
}

# ------------------------------------------------------------
# 10. Check Service Principal (optional)
# ------------------------------------------------------------
# Write-Host "`nChecking Service Principal (optional for CI/CD)..."

# $spVars = @(
#     "ARM_CLIENT_ID",
#     "ARM_CLIENT_SECRET",
#     "ARM_TENANT_ID",
#     "ARM_SUBSCRIPTION_ID"
# )

# foreach ($v in $spVars) {
#     Check-Step "$v environment variable set" ($env:$v -ne $null)
# }

# Write-Host "`nIf CI/CD variables are FAIL, create SP:" -ForegroundColor Yellow
# Write-Host "az ad sp create-for-rbac --name terraform-sp --role Owner --scopes /subscriptions/<SUB_ID>" -ForegroundColor Yellow

# # ------------------------------------------------------------
# # Final summary
# # ------------------------------------------------------------
# Write-Host "`n=== Prerequisite Check Complete ===" -ForegroundColor Cyan
# Write-Host "Fix any FAIL items before running Terraform." -ForegroundColor Yellow
