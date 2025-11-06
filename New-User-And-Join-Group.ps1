<# 
  New-User-And-Join-Group.ps1
  Enkel demo: Opprett en Entra ID-bruker og meld vedkommende inn i en sikkerhetsgruppe.
#>

# 0) Koble til Graph (be om interaktiv pålogging med riktige scopes om nødvendig)
if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All" | Out-Null
}

# 1) Funksjon: Opprett bruker
function New-StudentUser {
  <#
  .SYNOPSIS  Opprett en ny Entra ID-bruker med passordprofil.
  #>
  param(
    [Parameter(Mandatory)][string]$DisplayName,
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)][string]$MailNickname,
    [Parameter(Mandatory)][string]$Password
  )

  $pwdProfile = @{
    Password = $Password
    ForceChangePasswordNextSignIn = $true
  }

  try {
    $user = New-MgUser `
      -DisplayName $DisplayName `
      -UserPrincipalName $UserPrincipalName `
      -MailNickname $MailNickname `
      -AccountEnabled:$true `
      -PasswordProfile $pwdProfile `
      -ErrorAction Stop
    return $user
  }
  catch {
    throw "Klarte ikke å opprette bruker $UserPrincipalName : $($_.Exception.Message)"
  }
}

# 2) Funksjon: Meld bruker inn i gruppe (New-MgGroupMember)
function Add-UserToGroup {
  <#
  .SYNOPSIS  Legg en bruker inn i en (sikkerhets)gruppe.
  #>
  param(
    [Parameter(Mandatory)][string]$UserIdOrUpn,
    [Parameter(Mandatory)][string]$GroupName
  )

  $user  = Get-MgUser  -UserId $UserIdOrUpn -ErrorAction Stop
  $group = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction Stop
  if (-not $group) { throw "Fant ikke gruppe '$GroupName'." }

  try {
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id -ErrorAction Stop | Out-Null
    return "La til $($user.DisplayName) i gruppen '$($group.DisplayName)'."
  }
  catch {
    throw "Klarte ikke å legge til medlem: $($_.Exception.Message)"
  }
}

# 3) Hovedflyt – enkel inputdialog
Write-Host "=== Opprett bruker og meld inn i gruppe (Graph) ===" -ForegroundColor Cyan

$displayName = Read-Host "DisplayName (f.eks. Ola Nordmann)"
$upn         = Read-Host "UserPrincipalName (f.eks. ola.nordmann@contoso.onmicrosoft.com)"
$mailNick    = Read-Host "MailNickname (f.eks. ola.nordmann)"
$groupName   = Read-Host "Gruppenavn (DisplayName)"
$password    = Read-Host "Startpassord (bruker må bytte ved første innlogging)"

# Opprett gruppe hvis den mangler (sikkerhetsgruppe)
$existingGroup = Get-MgGroup -Filter "displayName eq '$groupName'"
if (-not $existingGroup) {
  Write-Host "Oppretter sikkerhetsgruppe '$groupName'..." -ForegroundColor Yellow
  $grpParams = @{
    DisplayName     = $groupName
    Description     = "Opprettet av demo-skript"
    MailEnabled     = $false
    SecurityEnabled = $true
    MailNickname    = ($groupName -replace '\s','-').ToLower()
  }
  $existingGroup = New-MgGroup @grpParams
}

# Opprett bruker
$user = New-StudentUser -DisplayName $displayName -UserPrincipalName $upn -MailNickname $mailNick -Password $password
Write-Host "Bruker opprettet: $($user.DisplayName) ($($user.UserPrincipalName))" -ForegroundColor Green

# Legg i gruppe
$result = Add-UserToGroup -UserIdOrUpn $user.Id -GroupName $groupName
Write-Host $result -ForegroundColor Green

Write-Host "Ferdig! 🎉" -ForegroundColor Cyan