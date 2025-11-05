# 💻 Introduksjon: Installere PowerShell 7

PowerShell 7 er den nyeste versjonen av PowerShell, og fungerer på **Windows**, **macOS** og **Linux**.  
Denne veiviseren hjelper deg å installere PowerShell 7 på **Windows** og **Mac**, ved hjelp av **pakkehåndteringsverktøyene** Chocolatey og Homebrew.

---

## 🧭 Før du starter

### Hva er PowerShell?
PowerShell er et kommandolinjeverktøy og skriptspråk som gjør det mulig å automatisere og administrere systemer mer effektivt.  
Du kan bruke PowerShell til å utføre oppgaver som:
- Administrere filer og mapper
- Automatisere oppgaver i Windows eller Azure
- Hente informasjon om systemer
- Utføre konfigurasjon på tvers av mange maskiner

---

## 🪟 Installasjon på Windows

### 1. Kontroller at du har **Administrator-rettigheter**
Du må kjøre kommandolinjen som administrator for å installere programmer via **Chocolatey**.

### 2. Installer **Chocolatey** (hvis du ikke allerede har det)
Chocolatey er en pakkehåndterer for Windows – som gjør det enkelt å installere programmer direkte fra kommandolinjen.

**Slik installerer du Chocolatey:**

1. Åpne **PowerShell som Administrator**  
   - Søk etter *PowerShell* i startmenyen  
   - Høyreklikk og velg **Kjør som administrator**

2. Kjør følgende kommando (kopier og lim inn):
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; `
   [System.Net.ServicePointManager]::SecurityProtocol = `
   [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

3. Når installasjonen er ferdig, lukk og åpne PowerShell på nytt.

4. Sjekk at Chocolatey fungerer:

   ```powershell
   choco --version
   ```

   Hvis du ser et versjonsnummer, er alt klart!

---

### 3. Installer **PowerShell 7** via Chocolatey

Nå kan du installere PowerShell 7 med én enkel kommando:

```powershell
choco install powershell -y
```

Flagget `-y` betyr at du automatisk godtar installasjonsbekreftelsen.

---

### 4. Start PowerShell 7

Etter installasjonen kan du starte PowerShell 7 ved å:

* Søke etter **PowerShell 7** i Startmenyen, eller
* Skrive `pwsh` i kommandolinjen.

---

### 5. (Valgfritt) Gjør PowerShell 7 til standard

Hvis du ønsker at PowerShell 7 skal åpnes som standard når du skriver `powershell` i terminalen, kan du oppdatere snarveier eller legge `pwsh.exe` inn i PATH.
Dette er valgfritt, men kan være nyttig hvis du bruker PowerShell ofte.

---

## 🍎 Installasjon på macOS

### 1. Installer **Homebrew** (hvis du ikke allerede har det)

Homebrew er den mest brukte pakkehåndtereren for macOS.

Åpne **Terminal** og kjør følgende kommando:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Følg instruksjonene på skjermen.
Når installasjonen er ferdig, skriv:

```bash
brew --version
```

for å sjekke at Homebrew fungerer.

---

### 2. Installer PowerShell 7 via Homebrew

Når Homebrew er klart, kan du installere PowerShell 7 med én kommando:

```bash
brew install --cask powershell
```

Dette laster ned og installerer den nyeste versjonen av PowerShell.

---

### 3. Start PowerShell

Etter installasjonen kan du starte PowerShell ved å skrive:

```bash
pwsh
```

Du skal nå se PowerShell-prompten:

```
PS /Users/navn>
```

---

### 4. (Valgfritt) Gjør PowerShell lettere tilgjengelig

Hvis du ønsker å starte PowerShell 7 fra Launchpad, kan du finne den under **Applications → PowerShell**.
Du kan også feste den til Dock for rask tilgang.

---

## ✅ Test installasjonen

Uansett hvilket operativsystem du bruker, kan du teste PowerShell 7 ved å skrive følgende kommando:

```powershell
$PSVersionTable.PSVersion
```

Dette skal vise noe som ligner på:

```
Major  Minor  Build  Revision
-----  -----  -----  --------
7      4      0      0
```

Da vet du at PowerShell 7 fungerer som det skal!

---

## 🧩 Oppsummering

| Operativsystem | Pakkehåndterer | Installasjonskommando            |
| -------------- | -------------- | -------------------------------- |
| Windows        | Chocolatey     | `choco install powershell -y`    |
| macOS          | Homebrew       | `brew install --cask powershell` |

---

## 💡 Tips

* Du kan alltid avinstallere PowerShell 7 ved å skrive:

  * **Windows:** `choco uninstall powershell -y`
  * **macOS:** `brew uninstall --cask powershell`
* Bruk `pwsh` for å starte PowerShell 7 på tvers av alle plattformer.
* Husk at eldre versjoner (Windows PowerShell 5.1) fortsatt finnes på Windows, men PowerShell 7 er **kryssplattform** og anbefales for all ny bruk.

---

### 🎯 Neste steg

Når PowerShell er installert og fungerer, er du klar til å begynne å lære de første kommandoene — for eksempel hvordan du navigerer i mapper, oppretter filer og bruker variabler!

```

---

Vil du at jeg skal lage en **fortsettelse** av denne veiviseren som tar for seg *hvordan man åpner og bruker PowerShell første gang* (f.eks. navigasjon, hjelp-systemet, `Get-Command`, `Get-Help`, osv.) — slik at studentene får en god start etter installasjonen?
```
