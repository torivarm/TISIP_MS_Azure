# Kan også sette til RemoteSigned i stedet for unrestricted
Set-ExecutionPolicy -ExecutionPolicy unrestricted -Scope LocalMachine


# Installere Choco 
# Hva er Choco: https://chocolatey.org/
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Oppgradere til siste versjon av Choco
choco upgrade chocolatey

# Installere programvare med Choco
choco install -y powershell-core
choco install -y vscode

# Installer Az Modulen
Install-Module -Name Az
Get-InstalledModule

# For å komme direkte til Microsoft Docs siden til en cmdlet kan en bruke Get-Help <cmdlet> -Online
# Az-cmdlets forutsetter at en har Az Modulen installert (Instal-module)
Get-Help Connect-AzAccount -Online

# Kobler til Azure
Connect-AzAccount 

Get-AzTenant
Get-AzContext

$tenant = Get-AzTenant | Where-Object {$_.name -like "*Demo*" } 
Set-AzContext -TenantId $tenant.id

<# Management Groups
Management groups are containers that help you manage access, policy, and compliance across multiple subscriptions.
Create these containers to build an effective and efficient hierarchy that can be used with Azure Policy and
Azure Role Based Access Controls
Navngivningforslag: mg-<business unit>[-<environment type>]
#>

# Ny Management groups
New-AzManagementGroup -GroupID 'mg-it-tmp' -DisplayName 'MGMT IT TMP'
Get-help Get-AzManagementGroup -Online
Get-help Remove-AzManagementGroup -Online


# Lag hierarki 
$parentGroup = Get-AzManagementGroup -GroupID 'mg-it-tmp'
New-AzManagementGroup -GroupID 'mg-it-prod-tmp' -ParentId $parentGroup.id
New-AzManagementGroup -GroupID 'mg-it-dev-tmp' -ParentId $parentGroup.id
New-AzManagementGroup -GroupID 'mg-it-test-tmp' -ParentId $parentGroup.id

Get-AzManagementGroup
# MERK: Vi har kun opprettet MGMT Groups, det er ikke satt rettigheter eller lagt noen subscription i disse gruppene.




# OPPRETTE RESSURSER - Variabler med navn vi skal bruke senere
$rgname = "rg-undervisning-demo-001"
$location = "norwayeast"
$saname = "sttim001"
$fsname = "fs-demo001-norwayeast"

New-AzResourceGroup -Name "rg-undervisning-demo-001" -Location "norwayeast"
New-AzResourceGroup -Name $rgname -Location $location
# Remove-AzResourceGroup -Name $rgname
# Om en lurer på Location: Get-AzLocation

Get-AzResourceGroup
Get-AzResourceGroup | Format-Table # Format-Table kan bruke alias ft

# Oppretter storage account. MERK av vi bruker en fnutt på enden av setningene for å bryte opp setningen.
# Kommandoen vil ikke fungere uten `-tegnet om en bryter linjen. Da må kommandoen kjøre på en og samme linje,
# som gjør det mindre oversiktlig om det er mye innhold i kommandoen.
# Get-Help New-AzStorageAccount -Online
$storageaccount = New-AzStorageAccount -ResourceGroupName $rgname `
    -Name $saname `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2

# https://docs.microsoft.com/en-us/powershell/module/az.storage/new-azstorageshare?view=azps-7.3.0
$ctx = (Get-AzStorageAccount -ResourceGroupName $rgname -Name $saname).Context  
$fileshare = New-AzStorageShare -Context $ctx -Name $fsname

# TAGS
# Get-Help New-AzTags -Online
# Get-Help Set-AzResourceGroupe -Online
$Tags = @{"costcenter"="12345"; "owner"="tor.i.melling@tisipfagskole.no"}
# Henter id til resource group
$rginfo = Get-AzResourceGroup -Name $rgname
# Setter Tags på Resource Group (begge linjene under gjør det samme) 
# Merk at en overskriver eksisterende Tags med samme kommando 
New-AzTag -Tag $Tags -ResourceId $rginfo.ResourceId
Set-AzResourceGroup -Name $rgname -Tag $tags

# Erstatt eller oppdater
$Tags = @{"department"="it"}
Update-AzTag -ResourceId $rginfo.ResourceId -Tag $Tags -Operation Merge

# For å liste ut Resource Group eller Resource basert på Tag
Get-AzResourceGroup -Tag @{'owner'='tor.i.melling@tisipfagskole.no'} | ft
Get-AzResource -Tag @{'owner'='tor.i.melling@tisipfagskole.no'} | ft

$sainfo = Get-AzStorageAccount -Name $saname -ResourceGroupName $rgname
Set-AzStorageAccount -Name $saname -ResourceGroupName $rgname -Tag $tags
New-AzTag -ResourceId $sainfo.id -Tag $tags

Get-Help Remove-AzTag -Online



<# Create Users in Azure
Get-Help New-AzADUser -Online
Get-Help Get-AzADUser -Online
Get-Help Update-AzADUser -Online
Get-Help Remove-AzADUser -Online
Get-Help Import-Csv -Online
#>
$newUsers = Import-Csv my-users-azure.csv -Delimiter ";"


foreach ($user in $newUsers) {
    $SecureStringPassword = ConvertTo-SecureString -String $user.Password -AsPlainText -Force
    New-AzADUser -DisplayName $user.DisplayName `
        -UserPrincipalName $user.UserPrincipalName `
        -Password $SecureStringPassword `
        -MailNickname $user.MailNickName
}

Get-Help New-AzADUser -Online

foreach ($user in $newUsers) {
    $usercheck=Get-AzADUser -UserPrincipalName $user.UserPrincipalName
    if (!$usercheck) {
        Write-Host "User $user.UserPrincipalName not found. Createing user $user.UserPrincipalName" -ForegroundColor Green
        $SecureStringPassword = ConvertTo-SecureString -String $user.Password -AsPlainText -Force
        New-AzADUser -DisplayName $user.DisplayName `
            -UserPrincipalName $user.UserPrincipalName `
            -Password $SecureStringPassword `
            -MailNickname $user.MailNickName
    }
    if ($usercheck) {
        "User $user.UserPrincipalName found. User not created but will be updated with information from CSV" -ForegroundColor Green
        # Update-AzADUser
        # Her kan en velge om en skal oppdatere informasjon til allerede eksisterende brukere, eventuelt slette de
        # Remove-AzADUser -UserPrincipalName $user.UserPrincipalName -Confirm:$false
    }
}

<# Tildel rolle til bruker
New-AzRoleassignment - https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azroleassignment?view=azps-7.3.2
Get-AzRoleassignment - https://docs.microsoft.com/en-us/powershell/module/az.resources/get-azroleassignment?view=azps-7.3.2
Remove-AzRoleassignment - https://docs.microsoft.com/en-us/powershell/module/az.resources/remove-azroleassignment?view=azps-7.3.2
#>
# For å finne rollene
$roledef = Get-AzRoleDefinition # Veldig veldig lang liste
Get-AzRoleDefinition | Where-Object -Property Name -eq 'Owner'
Get-AzRoleDefinition | Where-Object -Property Name -eq 'Reader'
Get-AzRoleDefinition | Where-Object -Property Name -like '*Virtual Machine*' | ft

$location = 'norwayeast'
$rgrbac = 'rg-demo-rbac'
$rbacgroup = 's_demogroup-rbac'
New-AzResourceGroup -Name $rgrbac -Location $location
$newgroup = new-azadgroup -DisplayName $rbacgroup -MailNickname $rbacgroup
$newgroup

$demouser = Get-AzADUser -UserPrincipalName 'Pernille.Hansen@azdemoundervisning.onmicrosoft.com'

# Merk at hvis en ikke spesifisere hvor rollen skal settes på den under, vil den velge subscription:
New-AzRoleAssignment -ObjectId $newgroup.Id -RoleDefinitionName Contributor -ResourceGroupName $rgrbac
New-AzRoleAssignment -ResourceGroupName $rgrbac -SignInName $demouser.UserPrincipalName -RoleDefinitionName Reader


Add-AzADGroupMember -TargetGroupObjectId $newgroup.id -MemberUserPrincipalName $demouser.UserPrincipalName

$rolesrg = Get-AzRoleAssignment -ResourceGroupName $rgrbac | Select-Object DisplayName,RoleDefinitionName

Remove-AzResourceGroup -Name $rgrbac

$delrg | foreach {Remove-AzResourceGroup -ResourceGroupName $_.ResourceGroupName -Force -AsJob}


<# Locks #>

$rglocks = 'rg-demo-lock'
$location = 'norwayeast'
$rglockname = 'RG-Lock'

1..5 | foreach { 
    New-AzResourceGroup -Name $rglocks$_ -Location $location
}

$storageaccount = New-AzStorageAccount -ResourceGroupName "rg-demo-lock1" `
    -Name "sttim005" `
    -Location $location `
    -SkuName Standard_RAGRS `
    -Kind StorageV2

# -Locklevel Accepted values: CanNotDelete, ReadOnly
1..5 | foreach { 
    New-AzResourceLock -LockLevel CanNotDelete -LockName $rglockname -ResourceGroupName $rglocks$_
}

Get-AzResourceLock

# List ut basert på porarty ResourceName
Get-AzResourceLock
$getlock = Get-AzResourceLock | Where-Object -Property resourcename -eq 'RG-Lock'
$getlock.ResourceGroupName

$getlock | foreach {
    Remove-AzResourceLock -LockName 'RG-Lock' -ResourceGroupName $_.ResourceGroupName -Force
}

Get-Help New-AzResourceLock -Online

# Fjerne lock
Remove-AzResourceLock `
      -LockName 'RG-Lock' `
      -ResourceGroupName $rglocks