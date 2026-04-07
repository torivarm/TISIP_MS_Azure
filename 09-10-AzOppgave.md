# Lab: Azure-administrasjon med PowerShell og Az-modulen

**Varighet:** 60–90 min  
**Målgruppe:** Studenter med Azure for Students-abonnement  
**Fokus:** Ressursgrupper, lagringskonto, nettverk, tags, locks og RBAC – med trygg opprydding

---

## 🎯 Læringsmål
Etter laben skal du kunne:
- Logge inn og sette riktig **kontekst** (tenant/abonnement)
- Opprette og administrere **ressursgrupper** og **enkle ressurser**
- Bruke **tags** for styring/kost/eierskap
- Beskytte ressurser med **resource locks** (CanNotDelete/ReadOnly)
- Tilordne **RBAC**-roller (f.eks. Reader) på ressursgruppe- eller ressursnivå
- Rydde opp trygt for å unngå kostnader

---

## ✅ Forutsetninger
- **PowerShell 7** (`pwsh`)
- **Az-modul** installert:
```powershell
  Install-Module Az -Scope CurrentUser
```

* Konto med tilgang til **Azure for Students** (du trenger *Contributor* eller tilsvarende i ditt abonnement)

---

## Del A – Logg inn og sett kontekst (5–10 min)

```powershell
# Logg inn
Connect-AzAccount

# Se abonnement og sett aktivt (velg student-abonnementet ditt)
Get-AzSubscription | Select Name, Id, State
$subscriptionName = "<Ditt Azure for Students-abonnement>"
Set-AzContext -Subscription $subscriptionName

# Bekreft
Get-AzContext
```

**Velg lokasjon (region):**

```powershell
Get-AzLocation | Select DisplayName, Location

$location = "norwayeast"   # eller westeurope
$rg       = "rg-student-<initialer>"  # eks: rg-student-ab
```

---

## 📦 Del B – Ressursgruppe + tags (10 min)

```powershell
# Opprett ressursgruppe med tags for eierskap og kost
New-AzResourceGroup -Name $rg -Location $location -Tag @{
  Owner      = "$env:USERNAME"
  Environment= "Dev"
  Course     = "DCST1001"
}

# Verifiser
Get-AzResourceGroup -Name $rg | Select ResourceGroupName, Location, Tags
```

> **Hvorfor tags?** Gjør det enkelt å filtrere, rapportere og rydde opp (styring/kost).

---

## 🗂️ Del C – Lagringskonto (kostnadsvennlig) (10–15 min)

```powershell
$stg = "st$(Get-Random)"  # unikt navn (kreves globalt)

New-AzStorageAccount `
  -Name $stg `
  -ResourceGroupName $rg `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2 `
  -AccessTier Hot `
  -AllowBlobPublicAccess:$false `
  -Tag @{ DataClass="Internal"; Backup="None" }

# Verifiser
Get-AzStorageAccount -ResourceGroupName $rg -Name $stg |
  Select StorageAccountName, SkuName, AccessTier, Location
```

---

## 🌐 Del D – Virtuelt nettverk (trygt og billig) (10–15 min)

```powershell
$vnetName   = "vnet-student-<initialer>"
$subnetName = "snet-app"

$subnetCfg = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.10.1.0/24"

New-AzVirtualNetwork `
  -Name $vnetName `
  -ResourceGroupName $rg `
  -Location $location `
  -AddressPrefix "10.10.0.0/16" `
  -Subnet $subnetCfg

# Verifiser
Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName |
  Select Name, Location, @{N="Subnets";E={$_.Subnets.Name -join ","}}
```

> **Tips:** Unngå VM i denne laben for å holde kostnaden minimal.

---

## 🔒 Del E – Resource locks (CanNotDelete & ReadOnly) (10 min)

**Lås ressursgruppen mot utilsiktet sletting:**

```powershell
New-AzResourceLock -LockName "rg-lock" -LockLevel CanNotDelete -ResourceGroupName $rg

# Les låser
Get-AzResourceLock -ResourceGroupName $rg | Select Name, Level, Notes
```

**Sett ReadOnly-lås på lagringskontoen:**

```powershell
New-AzResourceLock `
  -LockName "stg-readonly" `
  -LockLevel ReadOnly `
  -ResourceGroupName $rg `
  -ResourceType "Microsoft.Storage/storageAccounts" `
  -ResourceName $stg

# Verifiser
Get-AzResourceLock -ResourceGroupName $rg -AtScope
```

> **Merk:** Med ReadOnly kan ressurser ikke endres – fint for labbeskyttelse. Husk å **fjerne låser** før opprydding.

---

## 👥 Del F – RBAC (tilgang på RG- eller ressursnivå) (10–15 min)

**Gi en bruker (eller deg selv) rollen *Reader* på ressursgruppen.**

Finn principal (bruker) via UPN:

```powershell
$upn = "<din-UPN>@<tenant>.onmicrosoft.com"
$principalId = (Get-AzADUser -UserPrincipalName $upn).Id

$role = Get-AzRoleDefinition -Name "Reader"

# Tildel på RG-nivå
New-AzRoleAssignment -ObjectId $principalId -RoleDefinitionId $role.Id -ResourceGroupName $rg

# Verifiser
Get-AzRoleAssignment -ResourceGroupName $rg |
  Where-Object { $_.RoleDefinitionName -eq "Reader" } |
  Select PrincipalName, RoleDefinitionName, Scope
```

> **Hvorfor RG-nivå?** Arver til underliggende ressurser, enklere enn å tildele på hver ressurs.

---

## 🧰 Del G – Bonus: Idempotent funksjon + try/catch (5–10 min)

```powershell
function New-DemoResourceGroup {
  param([Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet("norwayeast","westeurope","northeurope","norwaywest")][string]$Location)

  $tags = @{ Owner=$env:USERNAME; Environment="Dev"; Course="DCST1001" }

  try {
    $existing = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
    if ($existing) { return $existing }
    New-AzResourceGroup -Name $Name -Location $Location -Tag $tags
  }
  catch {
    throw "Feil ved opprettelse av RG '$Name': $($_.Exception.Message)"
  }
}

# Bruk:
New-DemoResourceGroup -Name "rg-student-<initialer>-2" -Location $location
```

---

## 🧹 Del H – Opprydding (OBLIGATORISK) (5–10 min)

1. **Fjern ReadOnly-låsene** først, ellers får du ikke slettet:

```powershell
# Finn og slett alle låser i RG
Get-AzResourceLock -ResourceGroupName $rg | Remove-AzResourceLock -Force
```

2. **Slett ressursgruppen** (alt inni forsvinner):

```powershell
Remove-AzResourceGroup -Name $rg -Force -AsJob
```

> **Kontroller Portal/PowerShell** etter noen minutter for å sikre at alt er borte.

---

## 🧪 Mini-sjekk (underveis)

* `Get-AzResourceGroup -Name $rg`
* `Get-AzResource -ResourceGroupName $rg | Select Name, ResourceType`
* `Get-AzResourceLock -ResourceGroupName $rg`
* `Get-AzRoleAssignment -ResourceGroupName $rg | Select PrincipalName, RoleDefinitionName`

---

## 💡 Ekstraoppgaver (frivillig)

* Legg til/oppdater **tags** på alle ressurser i RG med en **ForEach-løkke**.
* Tildel **Reader**-rolle på ett spesifikt ressurs-scope (f.eks. lagringskontoens `Id`).
* Bruk `-WhatIf` på *Set/Remove*-cmdlets for trygg test.
* Eksporter en ressursoversikt til CSV:

  ```powershell
  Get-AzResource -ResourceGroupName $rg |
    Select Name, ResourceType, Location, ResourceGroupName |
    Export-Csv .\rg-inventory.csv -NoTypeInformation -Encoding UTF8
  ```

---

## 🧮 Vurderingskriterier (forslag)

| Kriterium                                          |   Poeng |
| -------------------------------------------------- | ------: |
| Riktig innlogging og kontekst (tenant/abonnement)  |      10 |
| RG + tags opprettet og verifisert                  |      15 |
| Storage/VNet opprettet med korrekte parametre      |      20 |
| Locks satt riktig (RG og ressurs) + verifisert     |      20 |
| RBAC-tilordning (Reader) + verifisert              |      20 |
| Opprydding gjennomført (låser fjernet, RG slettet) |      15 |
| **Sum**                                            | **100** |

---

## 🆘 Feilsøking

* **Autentisering/tenant feil:** `Disconnect-AzAccount` → `Connect-AzAccount` og velg riktig abonnement.
* **Navnekonflikt for storage:** velg et annet navn (må være globalt unikt).
* **Kan ikke slette RG:** du har sannsynligvis **locks** – fjern dem først.
* **RBAC feiler:** sørg for at du har rettigheter på abonnement/RG, og at `ObjectId` er korrekt (`Get-AzADUser`).

---