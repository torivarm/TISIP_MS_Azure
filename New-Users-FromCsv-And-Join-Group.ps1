<#
  New-Users-FromCsv-And-Join-Group.ps1
  Enkel bulk: Opprett mange brukere fra CSV og meld alle inn i én sikkerhetsgruppe.
  Logger resultat til en tidsstemplet loggfil i .\logs\
#>

# 0) Koble til Graph om nødvendig
if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All" | Out-Null
}

param(
  [Parameter(Mandatory)][string]$CsvPath,
  [Parameter(Mandatory)][string]$GroupName
)

# 1) Forbered logging
$logDir = Join-Path -Path (Get-Location) -ChildPath "logs"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }

$stamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$log    = Join-Path $logDir "bulk-log-$stamp.txt"

function Write-Log {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  $line | Out-File -FilePath $log -Append -Encoding UTF8
  Write-Host $line
}

Write-Log "=== Start bulk ==="
Write-Log "CSV: $CsvPath"
Write-Log "Group: $GroupName"

# 2) Funksjoner (samme som i interaktivt skript)
function New-StudentUser {
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
    New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
               -MailNickname $MailNickname -AccountEnabled:$true `
               -PasswordProfile $pwdProfile -ErrorAction Stop
  }
  catch {
    throw "Opprettelse feilet for $UserPrincipalName : $($_.Exception.Message)"
  }
}

function Add-UserToGroup {
  param(
    [Parameter(Mandatory)][string]$UserIdOrUpn,
    [Parameter(Mandatory)][string]$GroupName
  )
  $user  = Get-MgUser  -UserId $UserIdOrUpn -ErrorAction Stop
  $group = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction Stop
  if (-not $group) { throw "Fant ikke gruppe '$GroupName'." }

  try {
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id -ErrorAction Stop | Out-Null
    "OK: La til $($user.DisplayName) i '$($group.DisplayName)'."
  }
  catch {
    throw "Medlemskap feilet for $($user.UserPrincipalName) : $($_.Exception.Message)"
  }
}

# 3) Sikre at gruppen finnes (opprett hvis mangler)
$existingGroup = Get-MgGroup -Filter "displayName eq '$GroupName'"
if (-not $existingGroup) {
  Write-Log "Gruppe '$GroupName' finnes ikke – oppretter som sikkerhetsgruppe."
  $grpParams = @{
    DisplayName     = $GroupName
    Description     = "Opprettet av bulk-skript"
    MailEnabled     = $false
    SecurityEnabled = $true
    MailNickname    = ($GroupName -replace '\s','-').ToLower()
  }
  $existingGroup = New-MgGroup @grpParams
  Write-Log "Opprettet gruppe Id=$($existingGroup.Id)"
}

# 4) Les CSV og prosesser rad for rad
#    Forventer kolonner: DisplayName, UPN, MailNickname, Password
$rows = Import-Csv -Path $CsvPath

foreach ($r in $rows) {
  $dn  = $r.DisplayName
  $upn = $r.UPN
  $mn  = $r.MailNickname
  $pw  = $r.Password

  try {
    # Hopp over hvis brukeren allerede finnes (idempotent)
    $existing = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
    if ($existing) {
      Write-Log "INFO: Bruker finnes allerede: $upn – hopper opprettelse."
      # Men sørg for gruppemedlemskap likevel:
      $res = Add-UserToGroup -UserIdOrUpn $existing.Id -GroupName $GroupName
      Write-Log $res
      continue
    }

    $user = New-StudentUser -DisplayName $dn -UserPrincipalName $upn -MailNickname $mn -Password $pw
    Write-Log "OK: Opprettet $dn ($upn)."

    $res = Add-UserToGroup -UserIdOrUpn $user.Id -GroupName $GroupName
    Write-Log $res
  }
  catch {
    # NB: Ikke logg passord
    Write-Log "FEIL: $dn ($upn) – $($_.Exception.Message)"
  }
}

Write-Log "=== Ferdig bulk ==="
Write-Host "Logg lagret i: $log" -ForegroundColor Cyan