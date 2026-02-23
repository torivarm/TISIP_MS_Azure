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

Når du har satt riktig region, kopier og kjør scriptet i Azure CLI Web


---

## Feilsøking

**Feilmelding: `AuthorizationFailed` eller `not allowed in region`**
Din Azure for Students-konto har ikke tilgang til den valgte regionen. Gå tilbake til Steg 1 og velg en annen region.

**Feilmelding: `You must set the LOCATION variable`**
Du har glemt å bytte ut `<YOUR-LOCATION>` i scriptet. Åpne filen og gjør endringen.

**Usikker på hvilken region som er tillatt?**
Kontakt faglærer, eller forsøk deg frem med regionene i tabellen ovenfor.