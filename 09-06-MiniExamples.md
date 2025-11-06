# Microsoft Graph PowerShell – Opprett brukere og meld inn i gruppe

Denne veiviseren inneholder:
1) **Interaktivt skript** (én bruker om gangen)  
2) **Bulk-skript fra CSV** (mange brukere) med **enkel logging**  
3) **Eksempel-CSV**  

> Forutsetninger:
> - PowerShell 7 (`pwsh`)
> - Microsoft Graph PowerShell-modulen (`Install-Module Microsoft.Graph -Scope CurrentUser`)
> - Tilkobling med nødvendige scopes:
>   ```powershell
>   Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
>   ```

---

## 1) Interaktiv versjon (én bruker)

**Filnavn:** `New-User-And-Join-Group.ps1`

```powershell
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
````

**Kjøring:**

```powershell
.\New-User-And-Join-Group.ps1
```

---

## 2) Bulk fra CSV med enkel logging

**Filnavn:** `New-Users-FromCsv-And-Join-Group.ps1`

```powershell
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
```

**Kjøring:**

```powershell
# Eksempel:
.\New-Users-FromCsv-And-Join-Group.ps1 -CsvPath .\users.csv -GroupName "SG-App-Helpdesk"
```

---

## 3) Eksempel-CSV

**Filnavn:** `users.csv`

```csv
DisplayName,UPN,MailNickname,Password
Anna Hansen,anna.hansen@contoso.onmicrosoft.com,anna.hansen,P@ssw0rd1!
Bjørn Olsen,bjorn.olsen@contoso.onmicrosoft.com,bjorn.olsen,P@ssw0rd1!
Cathrine Berg,cathrine.berg@contoso.onmicrosoft.com,cathrine.berg,P@ssw0rd1!
```

> Tips:
>
> * Hold UPN og MailNickname konsistente med navnestandard.
> * Ikke gjenbruk svake passord i virkelige miljøer.
> * I produksjon: vurder å generere passord i skript og levere sikkert til brukeren, ikke via CSV.

---

## Vanlige feil & raske fiks

* **Mangler rettigheter/scopes:**
  Kjør `Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"` på nytt.
* **Gruppen finnes ikke:**
  Begge skript oppretter gruppen automatisk som **sikkerhetsgruppe**.
* **Bruker finnes allerede:**
  Bulk-skriptet hopper opprettelse og forsøker bare å sikre gruppemedlemskap (idempotent atferd).
* **Feil i CSV (manglende kolonner):**
  Sørg for kolonnene `DisplayName,UPN,MailNickname,Password`.

---

## Hva lærte vi? (kobling til grunnkurset)

* **Variabler og parametre:** Styrer navn og input inn i cmdletene.
* **Try/Catch:** Tydelige feilmeldinger og robust bulk-kjøring.
* **Funksjoner:** Gjenbrukbar logikk for bruker/medlemskap.
* **Pipelining/fil:** `Import-Csv` → løkke → Graph-kommandoer → logg til fil.

---