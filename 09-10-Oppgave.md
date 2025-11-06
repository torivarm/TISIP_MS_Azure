# Lab: Entra ID (Free) administrasjon med Microsoft Graph PowerShell

**Varighet:** 60–90 min  
**Målgruppe:** Studenter med Azure for Students-abonnement og Entra ID Free  
**Fokus:** Brukere, grupper, medlemskap, basis-roller og god praksis for passord

---

## 🎯 Læringsmål
Etter laben skal du kunne:
- Koble til Microsoft Graph med nødvendige rettigheter (delegert – scopes)
- Opprette brukere og sikkerhetsgrupper i Entra ID via PowerShell
- Melde brukere inn i grupper (New-MgGroupMember)
- Bygge enkle verktøyfunksjoner og bruke CSV for bulk
- Anvende grunnleggende passordpraksis og enkel logging
- (Valgfritt) Tilordne innebygd rolle (f.eks. **User Administrator**) til en testbruker

---

## ✅ Forutsetninger
- **PowerShell 7** (`pwsh`)
- Modul: `Microsoft.Graph` (installeres ved behov)
- En **Azure for Students**-tenant (Entra ID Free)
- Du er **Global administrator** i student-leietakeren, eller har nok rettigheter til å opprette brukere/grupper

**Sjekk/installer:**
```powershell
# Installer Graph-modulen (om nødvendig)
Install-Module Microsoft.Graph -Scope CurrentUser

# Koble til med minste nødvendige scopes for laben
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
Get-MgContext
````

---

## Navnestandard (bruk konsekvent prefiks)

```
Prefiks: ab # MERK! ab er brukt som prefix, så slipper en å få navnekonflikt med tidligere testing i egen Tenant
Bruker-UPN: ab.ola.nordmann@<ditt_tenantnavn>.onmicrosoft.com
Gruppe: SG-ab-Helpdesk
```

---

## Oppgaveoversikt

### Del A – Grunnoppsett og sanity checks (10–15 min)

1. Koble til Graph (se over).
2. Verifiser at du kan se brukere og grupper:

   ```powershell
   Get-MgUser -Top 3 | Select DisplayName, UserPrincipalName, Id
   Get-MgGroup -Filter "securityEnabled eq true" -Top 3 | Select DisplayName, Id
   ```
3. Opprett en **sikkerhetsgruppe** for laben (erstatt `ab` og tenant):

   ```powershell
   $groupName = "SG-ab-Helpdesk"
   $g = Get-MgGroup -Filter "displayName eq '$groupName'"
   if (-not $g) {
     $g = New-MgGroup -DisplayName $groupName -Description "Lab-gruppe for Helpdesk" `
          -MailEnabled:$false -SecurityEnabled:$true -MailNickname "sg-ab-helpdesk"
   }
   $g | Select DisplayName, Id
   ```

**Sjekkpunkt:** Du har gruppen på plass med en gyldig **Id**.

---

### Del B – Funksjoner (20 min)

Lag to enkle funksjoner i en fil `Lab-Graph-Tools.ps1`:

1. **Opprett bruker**
2. **Meld bruker inn i gruppe** (med `New-MgGroupMember`)

```powershell
# Lab-Graph-Tools.ps1

function New-StudentUser {
  param(
    [Parameter(Mandatory)][string]$DisplayName,
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)][string]$MailNickname,
    [Parameter(Mandatory)][string]$Password
  )
  $pwd = @{ Password = $Password; ForceChangePasswordNextSignIn = $true }
  try {
    New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
               -MailNickname $MailNickname -AccountEnabled:$true `
               -PasswordProfile $pwd -ErrorAction Stop
  }
  catch { throw "Opprettelse feilet for $UserPrincipalName : $($_.Exception.Message)" }
}

function Add-UserToGroup {
  param(
    [Parameter(Mandatory)][string]$UserIdOrUpn,
    [Parameter(Mandatory)][string]$GroupName
  )
  $u = Get-MgUser -UserId $UserIdOrUpn -ErrorAction Stop
  $g = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction Stop
  if (-not $g) { throw "Gruppe finnes ikke: $GroupName" }

  try {
    New-MgGroupMember -GroupId $g.Id -DirectoryObjectId $u.Id -ErrorAction Stop | Out-Null
    "OK: La til $($u.DisplayName) i $($g.DisplayName)"
  }
  catch { throw "Medlemskap feilet for $($u.UserPrincipalName) : $($_.Exception.Message)" }
}
```

**Test lokalt i sesjonen:**

```powershell
. .\Lab-Graph-Tools.ps1  # dot-source

$dn  = "ab Ola Nordmann"
$upn = "ab.ola.nordmann@<tenant>.onmicrosoft.com"
$mn  = "ab.ola.nordmann"
$pw  = "P@ssw0rd1!"  # lab – i prod: generer sikkert passord

$user = New-StudentUser -DisplayName $dn -UserPrincipalName $upn -MailNickname $mn -Password $pw
Add-UserToGroup -UserIdOrUpn $user.Id -GroupName "SG-ab-Helpdesk"
```

**Sjekkpunkt:** Bruker er opprettet og medlem av gruppen.
Verifiser:

```powershell
Get-MgUser -UserId $upn | Select DisplayName, UserPrincipalName
(Get-MgGroup -Filter "displayName eq 'SG-ab-Helpdesk'").Id |
  ForEach-Object { Get-MgGroupMember -GroupId $_ } |
  Where-Object {$_.Id -eq $user.Id} |
  Select DisplayName, Id
```

---

### Del C – Interaktivt miniskript (10–15 min)

Lag `New-User-And-Join-Group.ps1` som ber om input og bruker funksjonene dine:

```powershell
# New-User-And-Join-Group.ps1
if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All" | Out-Null
}

. .\Lab-Graph-Tools.ps1

$dn  = Read-Host "DisplayName"
$upn = Read-Host "UserPrincipalName"
$mn  = Read-Host "MailNickname"
$gn  = Read-Host "GroupName (eks. SG-ab-Helpdesk)"
$pw  = Read-Host "Startpassord (byttes ved første innlogging)"

# Opprett gruppa hvis den mangler
$g = Get-MgGroup -Filter "displayName eq '$gn'"
if (-not $g) {
  $g = New-MgGroup -DisplayName $gn -Description "Opprettet av miniskript" `
       -MailEnabled:$false -SecurityEnabled:$true -MailNickname ($gn -replace '\s','-').ToLower()
}

$u = New-StudentUser -DisplayName $dn -UserPrincipalName $upn -MailNickname $mn -Password $pw
Add-UserToGroup -UserIdOrUpn $u.Id -GroupName $gn
Write-Host "Ferdig. $dn opprettet og lagt i $gn." -ForegroundColor Green
```

**Kjør:**

```powershell
.\New-User-And-Join-Group.ps1
```

---

### Del D – Bulk fra CSV + enkel logging (15–25 min)

Lag `users.csv`:

```csv
DisplayName,UPN,MailNickname,Password
ab Anna Hansen,ab.anna.hansen@<tenant>.onmicrosoft.com,ab.anna.hansen,P@ssw0rd1!
ab Bjorn Olsen,ab.bjorn.olsen@<tenant>.onmicrosoft.com,ab.bjorn.olsen,P@ssw0rd1!
```

Lag `New-Users-FromCsv-And-Join-Group.ps1`:

```powershell
param(
  [Parameter(Mandatory)][string]$CsvPath,
  [Parameter(Mandatory)][string]$GroupName
)

if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All" | Out-Null
}

. .\Lab-Graph-Tools.ps1

# Logging
$logDir = Join-Path (Get-Location) "logs"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
$log = Join-Path $logDir ("bulk-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".txt")
function Write-Log([string]$m){ ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"),$m) | Out-File $log -Append }

# Sørg for at gruppa finnes
$g = Get-MgGroup -Filter "displayName eq '$GroupName'"
if (-not $g) {
  $g = New-MgGroup -DisplayName $GroupName -Description "Opprettet av bulk-skript" `
       -MailEnabled:$false -SecurityEnabled:$true -MailNickname ($GroupName -replace '\s','-').ToLower()
  Write-Log "Opprettet gruppe: $($g.DisplayName) / $($g.Id)"
}

# Behandle CSV
$rows = Import-Csv $CsvPath
foreach($r in $rows){
  try{
    $exists = Get-MgUser -UserId $r.UPN -ErrorAction SilentlyContinue
    if($exists){
      Write-Log "Finnes: $($r.UPN) – hopper opprettelse"
      $msg = Add-UserToGroup -UserIdOrUpn $exists.Id -GroupName $GroupName
      Write-Log $msg
      continue
    }
    $u = New-StudentUser -DisplayName $r.DisplayName -UserPrincipalName $r.UPN -MailNickname $r.MailNickname -Password $r.Password
    Write-Log "Opprettet: $($r.UPN)"
    $msg = Add-UserToGroup -UserIdOrUpn $u.Id -GroupName $GroupName
    Write-Log $msg
  } catch {
    Write-Log "FEIL: $($r.UPN) – $($_.Exception.Message)"
  }
}
Write-Host "Ferdig. Logg: $log" -ForegroundColor Cyan
```

**Kjør:**

```powershell
.\New-Users-FromCsv-And-Join-Group.ps1 -CsvPath .\users.csv -GroupName "SG-ab-Helpdesk"
```

**Sjekkpunkt:** Alle brukere i CSV er opprettet og medlemmer av gruppen.
Verifiser:

```powershell
(Get-MgGroup -Filter "displayName eq 'SG-ab-Helpdesk'").Id |
  ForEach-Object { Get-MgGroupMember -GroupId $_ } |
  Select DisplayName, Id
```

---

### Del E – (Valgfritt) Tilordne innebygd rolle til en testbruker (10 min)

> Krever at du selv har tilstrekkelige rettigheter.

```powershell
# Finn aktiverte roller
Get-MgDirectoryRole | Select DisplayName, Id

# Hvis "User Administrator" ikke finnes, aktiver den fra mal:
$tpl = Get-MgDirectoryRoleTemplate -All | Where-Object DisplayName -eq "User Administrator"
if ($tpl -and -not (Get-MgDirectoryRole | Where-Object DisplayName -eq "User Administrator")) {
  New-MgDirectoryRole -RoleTemplateId $tpl.Id | Out-Null
}

# Tildel rollen til én av lab-brukerne
$role = Get-MgDirectoryRole | Where-Object DisplayName -eq "User Administrator"
$u    = Get-MgUser -UserId "ab.anna.hansen@<tenant>.onmicrosoft.com"
New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -OdataId "/users/$($u.Id)"
```

**Sjekk:**

```powershell
Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Where-Object Id -eq $u.Id
```

---

### Del F – Rydd opp (5–10 min)

Når du er ferdig, slett testbrukere og eventuelle testgrupper:

```powershell
# Fjern brukere (OBS: permanent)
"ab.ola.nordmann@<tenant>.onmicrosoft.com",
"ab.anna.hansen@<tenant>.onmicrosoft.com",
"ab.bjorn.olsen@<tenant>.onmicrosoft.com" |
ForEach-Object {
  $u = Get-MgUser -UserId $_ -ErrorAction SilentlyContinue
  if($u){ Remove-MgUser -UserId $u.Id -Confirm:$false }
}

# Fjern gruppa
$g = Get-MgGroup -Filter "displayName eq 'SG-ab-Helpdesk'"
if($g){ Remove-MgGroup -GroupId $g.Id -Confirm:$false }
```

---

## 🔐 Passord – god praksis (kort)

* Bruk **tilfeldige passord** (≥ 12–16 tegn, blanding av store/små bokstaver, tall, spesialtegn).
* Sett alltid `ForceChangePasswordNextSignIn = $true`.
* Ikke logg passord i klartekst.
* Del påloggingsinfo via **trygg kanal** (ikke vanlig e-post i klartekst).
* Aktiver **MFA** ved første innlogging.

**Eksempler for rask generering (lab):**

```powershell
Add-Type -AssemblyName System.Web
[System.Web.Security.Membership]::GeneratePassword(14,3)

# eller
$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+'
-join (1..16 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
```

---

## 🧩 Leveranse (hva du leverer)

* `Lab-Graph-Tools.ps1`
* `New-User-And-Join-Group.ps1`
* `New-Users-FromCsv-And-Join-Group.ps1`
* `users.csv`
* `logs\bulk-*.txt` (fra bulk-skriptet)
* Kort **README.md** (1–2 avsnitt): hva du gjorde, hva som fungerte, hva som var vanskelig.

---

## 🧮 Vurderingskriterier (forslag)

| Kriterium                                                   |   Poeng |
| ----------------------------------------------------------- | ------: |
| Korrekt tilkobling og kontekst (scopes, validering)         |      10 |
| Funksjoner: opprett bruker + legg i gruppe (robusthet/feil) |      20 |
| Interaktivt skript (input, kontroll)                        |      10 |
| Bulk fra CSV (idempotens + logging)                         |      25 |
| God praksis for passord og opprydding                       |      15 |
| Dokumentasjon (README, struktur, navn)                      |      20 |
| **Sum**                                                     | **100** |

---

## 🆘 Feilsøking

* **Auth/consent-feil:** Kjør `Disconnect-MgGraph` og deretter `Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"` på nytt (aksepter samtykke).
* **Gruppen/brukeren finnes ikke:** Les feilmeldingen; opprett gruppen først, sjekk UPN-staving.
* **Rate limits:** Vent noen sekunder og kjør på nytt ved masseopprettelser.
* **MFA/Policy-blokkering:** Sjekk tenant-policy eller prøv en konto med riktige rettigheter.

God lab! 🚀

---