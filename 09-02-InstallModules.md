# Installere PowerShell-moduler (Az og MgGraph)

I denne delen lærer du hvordan du installerer og bruker **PowerShell-moduler** — spesielt modulene du trenger for å jobbe mot **Microsoft Azure**:
- **Az** – hovedmodulen for Azure-administrasjon
- **Microsoft.Graph** (MgGraph) – modulen for å jobbe mot EntraID

---

## 🧠 Hva er en PowerShell-modul?

En **modul** i PowerShell er en samling med kommandoer (cmdlets), funksjoner og ressurser som utvider PowerShell med nye muligheter.  
Moduler er som "apper" du installerer i PowerShell.

Eksempler:
- `Az` lar deg administrere Azure-ressurser (VM-er, nettverk, lagring)
- `Microsoft.Graph` lar deg jobbe med brukere, grupper og enheter i EntraID og Microsoft 365.
- `Pester` lar deg teste PowerShell-skript

---

## 📦 1. Sjekk hvor moduler lagres

Kjør denne kommandoen for å se hvilke mapper PowerShell bruker til å lagre moduler:

```powershell
$env:PSModulePath -split ';'
````

Du vil se flere stier (paths).
PowerShell laster moduler fra disse mappene automatisk når du importerer dem.

---

## 🧩 2. Finn en modul

For å søke etter moduler i PowerShell Gallery (nettbasert modul-bibliotek):

```powershell
Find-Module -Name Az
Find-Module -Name Microsoft.Graph
```

Dette viser deg informasjon om modulene, inkludert versjon og forfatter.

---

## 🔽 3. Installer moduler

Du må ha **Administrator-rettigheter** eller installere modulen for kun din bruker.

### Installer kun for din bruker (anbefalt): (for MacOS benyttes ikke Scope)

```powershell
Install-Module -Name Az -Scope CurrentUser
Install-Module -Name Microsoft.Graph -Scope CurrentUser
```

💡 **Forklaring:**

* `-Name` spesifiserer modulnavnet
* `-Scope CurrentUser` betyr at modulen installeres kun for deg (ikke for alle brukere)
* Du vil få spørsmål om å installere fra et "untrusted repository" første gang – svar **Y** (Yes)

---

### Alternativ: Installer for alle brukere (krever administrator)

```powershell
Install-Module -Name Az -Scope AllUsers
Install-Module -Name Microsoft.Graph -Scope AllUsers
```

---

## ✅ 4. Sjekk at modulene er installert

Etter installasjon kan du kontrollere hvilke moduler du har:

```powershell
Get-Module -ListAvailable | Where-Object Name -Match "Az|Graph"
```

Dette skal vise deg både **Az** og **Microsoft.Graph**-modulene.

---

## 5. Importer modulen (valgfritt)

PowerShell laster moduler automatisk når du bruker kommandoene deres,
men du kan også laste dem manuelt med:

```powershell
Import-Module Az
Import-Module Microsoft.Graph
```

---

## ☁️ 6. Logg inn mot Microsoft Azure

Når Az-modulen er installert, kan du logge inn i Azure direkte fra PowerShell:

```powershell
Connect-AzAccount
```

Et innloggingsvindu åpnes — logg inn med din **Azure-konto**.
Etterpå kan du for eksempel se hvilke abonnementer du har tilgang til:

```powershell
Get-AzSubscription
```

---

## 👤 7. Logg inn mot Microsoft Graph

For å jobbe mot EntraID, bruker du **Microsoft.Graph**-modulen.

Kjør:

```powershell
Connect-MgGraph
```

Et vindu for Microsoft-pålogging dukker opp.
Etter innlogging kan du for eksempel hente ut informasjon om deg selv:

```powershell
Get-MgUser -UserId me
```

---

## 8. Eksempler på nyttige kommandoer

### Med **Az**:

```powershell
# Liste alle ressursgrupper i abonnementet
Get-AzResourceGroup

# Opprette en ny ressursgruppe
New-AzResourceGroup -Name "Demo-RG" -Location "NorwayEast"
```

### Med **MgGraph**:

```powershell
# Liste brukere
Get-MgUser | Select DisplayName, UserPrincipalName

# Liste grupper
Get-MgGroup | Select DisplayName
```

---

## 🔄 9. Oppdatere moduler

Du kan enkelt oppdatere modulene til siste versjon:

```powershell
Update-Module -Name Az
Update-Module -Name Microsoft.Graph
```

For å se hvilke moduler som kan oppdateres:

```powershell
Get-InstalledModule
```

---

## 🧹 10. Avinstallere moduler (valgfritt)

Om du vil fjerne en modul:

```powershell
Uninstall-Module -Name Az
Uninstall-Module -Name Microsoft.Graph
```

---

## 🧾 Oppsummering

| Trinn | Handling                 | Kommando                                     |
| ----- | ------------------------ | -------------------------------------------- |
| 1     | Finn modul               | `Find-Module -Name Az`                       |
| 2     | Installer modul (bruker) | `Install-Module -Name Az -Scope CurrentUser` |
| 3     | Logg inn til Azure       | `Connect-AzAccount`                          |
| 4     | Logg inn til Graph       | `Connect-MgGraph`                            |
| 5     | Oppdater modul           | `Update-Module -Name Az`                     |

---

## 💡 Tips

* Installer alltid moduler **som CurrentUser** i undervisningsmiljøer for å unngå rettighetsproblemer.
* Du kan sjekke hvor modulen ble installert med:

  ```powershell
  Get-Module -Name Az -ListAvailable
  ```
* Når du jobber i VS Code, kan du kjøre kommandoene direkte i terminalen nederst i editoren.

---
