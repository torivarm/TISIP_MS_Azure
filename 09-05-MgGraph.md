# Entra ID med Microsoft Graph PowerShell (MgGraph)
**Mål:** Lære grunnleggende administrasjon av Entra ID (tidl. Azure AD) via Microsoft Graph PowerShell:
- Opprette brukere
- Opprette sikkerhetsgrupper (ikke-meldingsaktiverte)
- Legge brukere i grupper og tildele eiere
- (Valgfritt) Tilordne innebygde Entra-roller til brukere
- Masseoperasjoner fra CSV
- Robusthet med try/catch, funksjoner og parametre

> Knytning til PowerShell Grunnleggende:
> - **Variabler** (kap. 2) for navnestandard og gjenbruk  
> - **If/Switch** (kap. 3–4) for valg av miljø/handlingsgren  
> - **Løkker** (kap. 5) for masseendringer  
> - **Try/Catch** (kap. 6) for trygg kjøring  
> - **Funksjoner/Parametre** (kap. 7 & 10) for verktøyskript  
> - **Pipelining** (kap. 9) for filtrering og utsnitt

---

## 0) Koble til Microsoft Graph med riktige rettigheter (scopes)
```powershell
# Installer om nødvendig
# Install-Module Microsoft.Graph -Scope CurrentUser

# Koble til med minste nødvendige delegert tilgang for øvelsene:
Connect-MgGraph -TenantID "<SKRIV INN DIN TENANTID>" -Scopes `
  "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All","RoleManagement.ReadWrite.Directory"

# Bekreft tilkobling og profil
Get-MgContext
````

* **Hvorfor scopes?** Graph SDK følger «least privilege»; du må eksplisitt be om rettighetene skriptet trenger (i motsetning til gamle AzureAD-modulen). ([Microsoft Learn][1])

---

## 1) Finne fram: brukere og grupper

```powershell
# Finn bruker(e)
Get-MgUser -Filter "startsWith(displayName,'Student')" -All | Select DisplayName, UserPrincipalName, Id

# Finn grupper
Get-MgGroup -Filter "securityEnabled eq true" -All | Select DisplayName, Id
```

* **Pipelining** + **Select** gir ryddig output (kap. 9).

---

## 2) Opprette en ny bruker (basis)

```powershell
# Standardvariabler (kap. 2)
$upn = "ola.nordmann@<SKRIV INN DIN TENANT>.onmicrosoft.com" # MERK! navnet etter @ må matche med din Tenant!
$pwd = @{ Password = 'P@ssw0rd123!' ; ForceChangePasswordNextSignIn = $true }

# Opprett bruker
New-MgUser -DisplayName "Ola Nordmann" `
  -UserPrincipalName $upn `
  -MailNickname "ola.nordmann" `
  -AccountEnabled:$true `
  -PasswordProfile $pwd
```

* `New-MgUser` forventer et **PasswordProfile**-hashtable; bruk gjerne **ForceChangePasswordNextSignIn**. ([Microsoft Learn][2])

> 💡 Tips: Generer passord i skript (kap. 7 – funksjoner) og logg kun sikkert (ikke skriv passord til skjerm/fil).

---

## 3) Opprette en **sikkerhetsgruppe** (Entra ID Free-vennlig)

```powershell
$grpParams = @{
  DisplayName     = "SG-App-Helpdesk"
  Description     = "Tilgang til Helpdesk-appen"
  MailEnabled     = $false
  SecurityEnabled = $true
  MailNickname    = "sg-app-helpdesk"
}
New-MgGroup @grpParams
```

* Bruk **sikkerhetsgrupper** for tilgangsstyring på tvers av tjenester. `New-MgGroup` støtter både Microsoft 365-grupper og sikkerhetsgrupper; her velger vi sistnevnte. ([Microsoft Learn][3])

---

## 4) Legge en bruker i en gruppe

```powershell
# Hent Id-er
$user = Get-MgUser -UserId $upn
$group = Get-MgGroup -Filter "displayName eq 'SG-App-Helpdesk'"

# Legg til medlem ved referanse
New-MgGroupMember -GroupId $group.id -DirectoryObjectId $user.id
```

---

> ℹ️ **Entra ID Free** støtter tildeling av innebygde roller, men ikke avanserte funksjoner som PIM/Access Reviews/Dynamiske grupper.

---

## 6) Masseopprettelse fra CSV (variabler, løkker, try/catch) - MERK! her må en erstatte med eget Tenant navn.

**CSV: `users.csv`**

```csv
DisplayName,UPN,MailNickname,Password
Anna Hansen,anna.hansen@<SKRIV INN DIN TENANT>.onmicrosoft.com,anna.hansen,P@ssw0rd1!
Bjørn Olsen,bjorn.olsen@<SKRIV INN DIN TENANT>.onmicrosoft.com,bjorn.olsen,P@ssw0rd1!
```

**Script:**

```powershell
$groupName = "SG-App-Helpdesk"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

Import-Csv .\users.csv | ForEach-Object {
  try {
    $pwd = @{ Password = $_.Password ; ForceChangePasswordNextSignIn = $true }

    $u = New-MgUser -DisplayName $_.DisplayName `
                    -UserPrincipalName $_.UPN `
                    -MailNickname $_.MailNickname `
                    -AccountEnabled:$true `
                    -PasswordProfile $pwd `
                    -ErrorAction Stop

    # Legg i gruppe
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $u.Id -ErrorAction Stop

    Write-Host "Opprettet og lagt til: $($_.DisplayName)" -ForegroundColor Green
  }
  catch {
    Write-Host "Feil for $($_.UPN): $($_.Exception.Message)" -ForegroundColor Red
  }
}
```

* Viser **Import-Csv** (kap. 8), **løkker** (kap. 5) og **try/catch** (kap. 6).
* `-ErrorAction Stop` sørger for at catch fanger feil.

---

## 7) Oppdatere/Deaktivere/Slette brukere (CRUD)

```powershell
# Oppdatere (f.eks. avdeling)
Update-MgUser -UserId $upn -Department "IT"

# Midlertidig blokkere pålogging
Update-MgUser -UserId $upn -AccountEnabled:$false

# Slette (OBS!)
# Remove-MgUser -UserId $upn -Confirm:$false
```

---

## 8) Små verktøyfunksjoner (funksjoner & parametre) - Gjenbrukbare funksjoner som kan settes inn i script.
Disse funksjonene kan settes inn i script og kalles opp med kommandoen: New-StudentUser -DisplayName "Test Testesen" -UserPrincipalName "test.testesen@<ERSTATT MED DIN TENANT>.onmicrosoft.com" -MailNickname "test.testesen" -Password "SuperHemmeligPassord123!"

```powershell
function New-StudentUser {
  <#
  .SYNOPSIS  Opprett Entra-bruker m/standardpolicy
  #>
  param(
    [Parameter(Mandatory)] [string]$DisplayName,
    [Parameter(Mandatory)] [string]$UserPrincipalName,
    [Parameter(Mandatory)] [string]$MailNickname,
    [Parameter(Mandatory)] [string]$Password
  )

  $pwd = @{ Password = $Password ; ForceChangePasswordNextSignIn = $true }

  try {
    New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
               -MailNickname $MailNickname -AccountEnabled:$true -PasswordProfile $pwd `
               -ErrorAction Stop
  }
  catch { throw "Opprettelse feilet for $UserPrincipalName $($_.Exception.Message)" }
}

function Add-UserToGroup {
  param(
    [Parameter(Mandatory)][string]$UserIdOrUpn,
    [Parameter(Mandatory)][string]$GroupName
  )

  $u = Get-MgUser -UserId $UserIdOrUpn
  $g = Get-MgGroup -Filter "displayName eq '$GroupName'"
  New-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $u.Id
}
```

* Gjenbrukbare verktøy som demonstrerer **parametre** og **feilhåndtering** (kap. 6–7–10).

---

## 9) Eierskap og opprydding

```powershell
# Liste medlemmer
Get-MgGroupMember -GroupId $group.Id -All | Select DisplayName, Id

# Slett gruppe
# Remove-MgGroup -GroupId $group.Id -Confirm:$false
```

---

## 10) Mini-oppgaver (for studentene)

1. Lag 3 brukere fra CSV og plasser dem i **SG-App-Helpdesk**.
2. Oppdater **Department** for alle brukere i gruppen til `Support` (bruk **Get-MgGroupMember** + **ForEach-Object**)

---

## Vanlige cmdlets (hurtigoversikt)

| Oppgave                   | Cmdlet                                                | Hvorfor                                                               |
| ------------------------- | ----------------------------------------------------- | --------------------------------------------------------------------- |
| Koble til Graph           | `Connect-MgGraph`                                     | Delegert minste nødvendige scopes for øvelser. ([Microsoft Learn][1]) |
| Opprette bruker           | `New-MgUser`                                          | Opprett ny konto m/PasswordProfile. ([Microsoft Learn][2])            |
| Opprette sikkerhetsgruppe | `New-MgGroup`                                         | Sikkerhetsgruppe for tilgangsstyring. ([Microsoft Learn][3])          |

---

## Viktige begrensninger med Entra ID Free

* **Ingen dynamiske grupper** og **ingen gruppelisensiering**.
* Innebygde **roller** kan tilordnes, men avanserte styringsfunksjoner (PIM, access reviews) er ikke tilgjengelige.

---

## Beste praksis (kort)

* **Minste nødvendige scopes** når du kjører `Connect-MgGraph`.
* **Tags/standardnavn** i variabler for konsistens (kap. 2).
* **Idempotens**: sjekk om objekt finnes før opprettelse (if/try).
* **Logg feil** i `catch` og fortsett neste element i masseoperasjoner.
* **Rydd opp** i lab-ressurser: fjern testbrukere og grupper.

---
