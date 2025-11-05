# Grunnleggende Azure-administrasjon med Az (PowerShell)

Denne veiviseren viser hvordan du bruker **Az-modulen** til å administrere Azure fra PowerShell.  
Du trenger:
- PowerShell 7 (`pwsh`)
- Az-modulen installert (`Install-Module Az -Scope CurrentUser`)
- Pålogging til Azure (`Connect-AzAccount`)

> 🎓 Knytning til PowerShell Grunnleggende:
> - Variabler → lagre navn, lokasjoner, ressurser (kap. 2)
> - If/Else & Switch → valg av abonnement, lokasjon (kap. 3–4)
> - Løkker → masseoperasjoner (kap. 5)
> - Try/Catch → robust feilhandtering (kap. 6)
> - Funksjoner & Parametre → verktøyskript (kap. 7 & 10)
> - Pipelining → filtrering, sortering, valg (kap. 9)

---

## Logg inn og velg riktig kontekst

```powershell
# Logg inn i Azure
Connect-AzAccount

# Se hvilke tenants og abonnement du har
Get-AzTenant | Select-Object Id, Name
Get-AzSubscription | Select-Object Name, Id, State

# Sett aktivt abonnement
$subscriptionName = "Contoso-Dev"
Set-AzContext -Subscription $subscriptionName

# Bekreft kontekst
Get-AzContext
````

**Hva & hvorfor?**

* *Context* styrer **hvilket abonnement** og **hvilken tenant** kommandoene dine jobber mot.
* Bruk **variabler** (kap. 2) for å unngå skrivefeil og gjøre skript gjenbrukbart.

---

## 1) Lokasjoner og ressursgrupper

**Lokasjoner (Regions):** hvor i verden ressursene plasseres.
**Ressursgruppe (RG):** logisk container for livssyklus, tilgang og kost.

```powershell
# Finn tilgjengelige lokasjoner
Get-AzLocation | Select-Object DisplayName, Location

# Velg standardverdier med variabler
$location = "norwayeast" # HUSK HER MÅ EN VELGE LOCATION SOM TILLATES AV SIN AZURE FOR STUDENT SUBSCRIPTION!!
$rg = "rg-demo-01"

# Opprett ressursgruppe
New-AzResourceGroup -Name $rg -Location $location

# Hent/vis RG
Get-AzResourceGroup -Name $rg

# Oppdater "tags" for styring og kostsporing
Set-AzResourceGroup -Name $rg -Tag @{ Environment="Dev"; Owner="Student01"; CostCenter="EDU" }
```

**Hvorfor?**

* **Tags** = bedre oversikt/kostkontroll.
* Bruk **parametre** og **variabler** for konsistens (kap. 2 og 10).

---

## 2) Søk, filtrer og pipe Azure-ressurser

```powershell
# Alle ressurser i RG
Get-AzResource -ResourceGroupName $rg

# Filtrer (Where-Object) og velg felter (Select-Object)
Get-AzResource -ResourceGroupName $rg |
  Where-Object { $_.ResourceType -like "Microsoft.Compute/*" } |
  Select-Object Name, ResourceType, Location
```

**Knytning:** *Pipelining* (kap. 9) gjør det lett å kombinere Az-kommandoer med PowerShell-filtering.

---

## 3) Opprett, hent og slett: CRUD på ressurser (eksempler)

### 3.1 Lagringskonto (Storage Account)

```powershell
$stg = "st" + (Get-Random)  # unikt navn
$sku = "Standard_LRS"

# Create
New-AzStorageAccount -Name $stg -ResourceGroupName $rg -Location $location -SkuName $sku -Kind StorageV2 -AccessTier Hot

# Read
Get-AzStorageAccount -ResourceGroupName $rg -Name $stg

# Update (legg til tags)
Set-AzStorageAccount -ResourceGroupName $rg -Name $stg -Tag @{ DataClass="Public"; Backup="Daily" }

# Delete
# Remove-AzStorageAccount -ResourceGroupName $rg -Name $stg -Force
```

### 3.2 Virtuelt nettverk (VNet) + Subnett

```powershell
$vnetName = "vnet-demo-01"
$subnetName = "snet-app"

$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.10.1.0/24"

New-AzVirtualNetwork `
  -Name $vnetName -ResourceGroupName $rg -Location $location `
  -AddressPrefix "10.10.0.0/16" -Subnet $subnet

Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg
```

### 3.3 Virtual Machine (VM) – hurtigstart

> Krever at du har/aksepterer image-terms ved første kjøring.

```powershell
$vmName = "vm-demo-01"
$cred = Get-Credential -Message "Oppgi lokal VM-admin"

New-AzVm `
  -Name $vmName -ResourceGroupName $rg -Location $location `
  -Image "Win2022Datacenter" -VirtualNetworkName $vnetName -SubnetName $subnetName `
  -PublicIpAddressName "$vmName-pip" -SecurityGroupName "$vmName-nsg" `
  -Credential $cred -Size "Standard_B2s"

# Start/stop/info
Stop-AzVM -Name $vmName -ResourceGroupName $rg -Force
Start-AzVM -Name $vmName -ResourceGroupName $rg
Get-AzVM -Name $vmName -ResourceGroupName $rg -Status
```

**Hvorfor disse?**

* Viser typisk **CRUD**-flyt og hvordan **parametre** styrer oppførsel (kap. 10).

---

## 4) Tagging, navnestandarder og kost (styring)

```powershell
# Legg til/endre tags på flere ressurser med ForEach (kap. 5)
$commonTags = @{ Environment="Dev"; Owner="Student01"; App="ContosoApp" }

Get-AzResource -ResourceGroupName $rg |
  ForEach-Object {
    Set-AzResource -ResourceId $_.ResourceId -Tag $commonTags -Force | Out-Null
  }

# Se kost (krever Cost Management-tilgang)
# Get-AzConsumptionUsageDetail -StartDate 2025-11-01 -EndDate 2025-11-05
```

**Hvorfor?**

* **Løkker** + **Set-AzResource** = rask masseredigering.
* Tagger muliggjør rapportering og governance.

---

## 5) Feilhåndtering (Try/Catch) og idempotens

```powershell
try {
    if (-not (Get-AzResourceGroup -Name $rg -ErrorAction Stop)) {
        New-AzResourceGroup -Name $rg -Location $location
    }
}
catch {
    Write-Host "Kunne ikke verifisere/opprette RG: $($_.Exception.Message)" -ForegroundColor Red
}
```

**Hvorfor?**

* **Try/Catch** (kap. 6) gjør skript trygge.
* **Idempotens**: Kjøring flere ganger gir samme resultat (sjekk før opprettelse).

---

## 6) Funksjoner: bygg egne Az-verktøy

```powershell
function New-DemoResourceGroup {
    <#
    .SYNOPSIS
        Oppretter en ressursgruppe med standardtags.
    .PARAMETER Name
        Navn på ressursgruppe
    .PARAMETER Location
        Azure-lokasjon (f.eks. norwayeast)
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateSet("norwayeast","norwaywest","westeurope","northeurope")]
        [string]$Location
    )

    $tags = @{ Environment="Dev"; Owner="$env:USERNAME"; App="EduDemo" }

    try {
        if (Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue) {
            Write-Host "RG finnes allerede: $Name" -ForegroundColor Yellow
            return (Get-AzResourceGroup -Name $Name)
        }
        else {
            return New-AzResourceGroup -Name $Name -Location $Location -Tag $tags
        }
    }
    catch {
        throw "Feil ved opprettelse av RG '$Name': $($_.Exception.Message)"
    }
}

# Bruk:
New-DemoResourceGroup -Name "rg-demo-02" -Location "norwayeast"
```

**Knytning:** *Funksjoner* + *parametre* (kap. 7 & 10) = gjenbrukbare verktøy med validering.

---

## 7) Fil (CSV/JSON) → masseopprettelser

```powershell
# Eksempeldata (CSV): name,location
# rg-sales-01,norwayeast
# rg-hr-01,westeurope

$rgList = Import-Csv -Path ".\rg-list.csv"

foreach ($item in $rgList) {
    try {
        New-AzResourceGroup -Name $item.name -Location $item.location -Tag @{ Dept="Auto"; Import="CSV" } -ErrorAction Stop
        Write-Host "Opprettet $($item.name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Feil for $($item.name): $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

**Knytning:** *Import av datafiler* (kap. 8) + *løkker* (kap. 5) + *try/catch* (kap. 6).

---

## 8) Tilganger (RBAC) – gi en bruker rolle på en RG

```powershell
# Gi "Reader"-rolle til en bruker (ObjectId eller UPN via Graph-lookup)
$principalId = "<ObjectId-til-bruker-eller-gruppe>"
$role = Get-AzRoleDefinition -Name "Reader"

New-AzRoleAssignment -ObjectId $principalId -RoleDefinitionId $role.Id -ResourceGroupName $rg
```

**Hvorfor?**

* RBAC styrer hvem som kan gjøre hva.
* Kombiner gjerne med **Microsoft.Graph** for å finne brukere/grupper.

---

## 9) Miljøopprydding

```powershell
# Slett én og én ressurs (trygt, men tregere)
# Remove-AzResource -ResourceId <id> -Force

# Slett hele RG (alt inni fjernes)
Remove-AzResourceGroup -Name $rg -Force -AsJob
```

**Hvorfor?**

* Unngå kost – rydd etter deg.
* `-AsJob` lar sletting kjøre i bakgrunnen fra din sesjon (merk: tar tid).

---

## 10) Mini-oppgaver (praktiske øvelser)

1. **Standardoppsett**

   * Sett `$location = "norwayeast"` og `$rg = "rg-student-<dittnavn>"`
   * Opprett RG og legg på tags: `Owner`, `Environment`, `Course`

2. **Lagring**

   * Opprett en lagringskonto med tilfeldig navn og `Standard_LRS`
   * Legg til tag `DataClass=Internal`
   * Hent kontoen og skriv ut *Name, Location, PrimaryEndpoints*

3. **Nettverk + VM**

   * Opprett VNet `10.20.0.0/16` og subnett `10.20.1.0/24`
   * Opprett en liten Windows VM i subnettet (B-serie)
   * Stopp VM, start den igjen, hent status

4. **RBAC**

   * Tildel `Reader`-rolle på RG til en test-bruker (ObjectId)
   * Verifiser rolleoppdrag (`Get-AzRoleAssignment`)

5. **CSV-import**

   * Lag en `rg-list.csv` og opprett flere RG-er i en løkke
   * Bruk `try/catch` og logg feil til fil

---

## Vanlige Az-kommandonavn (hurtigoversikt)

| Oppgave            | Cmdlets (Az)                                                    | Hvorfor                              |
| ------------------ | --------------------------------------------------------------- | ------------------------------------ |
| Login/kontekst     | `Connect-AzAccount`, `Set-AzContext`, `Get-AzSubscription`      | Velg riktig abonnement før du jobber |
| RG                 | `New-/Get-/Set-/Remove-AzResourceGroup`                         | Livssyklusbeholder + tagging         |
| Ressurser generelt | `Get-/Set-/Remove-AzResource`                                   | Søk/endre på tvers av typer          |
| Lagring            | `New-/Get-/Set-/Remove-AzStorageAccount`                        | Billig, robust lagring               |
| Nettverk           | `New-/Get-AzVirtualNetwork`, `New-AzVirtualNetworkSubnetConfig` | Nettverkstopologi                    |
| VM                 | `New-/Get-/Start-/Stop-AzVM`                                    | Compute-ressurser                    |
| RBAC               | `Get-AzRoleDefinition`, `New-/Get-AzRoleAssignment`             | Tilgangsstyring                      |
| Kost               | `Get-AzConsumptionUsageDetail`                                  | Kost/forbruk (tilgang kreves)        |

---

## Beste praksis (kort)

* **Bruk variabler og parametre** for gjenbrukbarhet.
* **Valider input** med `ValidateSet`, `ValidatePattern` (kap. 10).
* **Try/Catch** + `-ErrorAction Stop` for klar feilhåndtering (kap. 6).
* **Idempotens**: sjekk om noe finnes før du oppretter (kap. 3/6).
* **Tags** fra dag 1: `Environment`, `Owner`, `CostCenter`, `App`.
* **Rydd opp** ressurser i lab-miljøer.

---