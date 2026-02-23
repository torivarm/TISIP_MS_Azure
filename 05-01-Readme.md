# Veiledning: Sett riktig Azure-region før du kjører scriptet

## Bakgrunn

Azure for Students-abonnementer har begrensninger på hvilke Azure-regioner (locations) du kan opprette ressurser i. Disse regionene varierer fra student til student og kan endre seg over tid. Scriptet krever derfor at du selv setter riktig region før du kjører det.

---

## Steg 2 – Sett LOCATION-variabelen i scriptet

Kopier scriptet til eksempelvis VS Code (MacOS og Windows), Notepad(Windows), TextEdit(MacOS)


```bash
LOCATION="<YOUR-LOCATION>"   # <-- Change this value, e.g. "norwayeast"
```

Bytt ut `<YOUR-LOCATION>` med en av dine tillatte regioner. Eksempler på vanlige regioner:

| Visningsnavn        | Region-navn (bruk denne) |
|---------------------|--------------------------|
| Norway East         | `norwayeast`             |
| Norway West         | `norwaywest`             |
| North Europe        | `northeurope`            |
| West Europe         | `westeurope`             |
| Sweden Central      | `swedencentral`          |
| UK South            | `uksouth`                |

Eksempel på en ferdig utfylt linje:

```bash
LOCATION="norwayeast"
```

---

## Steg 3 – Kjør scriptet

## Steg 1 – Åpne Azure Cloud Shell

Azure Cloud Shell er en nettleserbasert bash-terminal som er innebygd i Azure Portal. Du trenger ikke installere noe – Azure CLI er allerede tilgjengelig der.

1. Gå til [portal.azure.com](https://portal.azure.com) og logg inn
2. Klikk på **Cloud Shell**-ikonet i toppmenyen (ser ut som `>_`)
3. Velg **Bash** hvis du blir spurt om shell-type
4. Første gang du åpner Cloud Shell blir du bedt om å opprette en lagringskonto – her kan du velge å starte Cloud Shell uten storage account, eller godta opprettelse av storage account. Førstnevnte går raskest.

Cloud Shell åpnes som et panel nederst i nettleseren og er klar til bruk.

---

## Feilsøking

**Feilmelding: `AuthorizationFailed` eller `not allowed in region`**
Din Azure for Students-konto har ikke tilgang til den valgte regionen. Gå tilbake til Steg 1 og velg en annen region.

**Feilmelding: `You must set the LOCATION variable`**
Du har glemt å bytte ut `<YOUR-LOCATION>` i scriptet. Åpne filen og gjør endringen.

**Usikker på hvilken region som er tillatt?**
Kontakt faglærer, eller forsøk deg frem med regionene i tabellen ovenfor.