# Gruppe 4 – Case: Ung Kultur Trondheim

## Bedriftsbeskrivelse

Ung Kultur Trondheim er en frivillig organisasjon med fire ansatte og rundt 60 aktive frivillige. De arrangerer konserter, workshops og kulturarrangementer. I dag bruker de en blanding av private e-postadresser, WhatsApp og USB-pinner for å dele informasjon, noe som skaper kaos og gjør det vanskelig å finne igjen dokumenter og kommunikasjon fra tidligere prosjekter.

**Behov:** Et felles sted å lagre og samarbeide om dokumenter, enkel kommunikasjon mellom ansatte og frivillige, og mulighet for å gi frivillige begrenset tilgang uten at det koster for mye per bruker.

**Begrensning:** Organisasjonen har svært begrenset budsjett og er avhengig av rimelige eller gratis løsninger. De frivillige har varierende teknisk kompetanse og bruker ulike enheter (mobil, nettbrett, PC).

---

## Oppgave

Design en Azure-løsning for Ung Kultur Trondheim. Tegn opp arkitekturen som et enkelt diagram (på papir, whiteboard eller digitalt) og forklar hvilke tjenester dere har valgt og hvorfor. Dere skal presentere løsningen for resten av klassen.

> **Tips:** Undersøk om det finnes egne Microsoft-programmer eller rabatter for ideelle organisasjoner – dette kan påvirke løsningen dere velger.

---

## Azure-bibliotek – Relevante tjenester for dette caset

Bruk tabellen nedenfor som utgangspunkt. Dere velger selv hvilke tjenester dere vil inkludere i løsningen – og dere kan godt argumentere for tjenester som ikke står på listen dersom dere mener de passer.

| Tjeneste | Kort beskrivelse | Dokumentasjon |
|---|---|---|
| **Microsoft Entra ID** | Identitets- og tilgangsstyring. Gjør det enkelt å legge til og fjerne brukere, og styre hvem som har tilgang til hva. | [Les mer](https://learn.microsoft.com/nb-no/entra/identity/fundamentals/whatis) |
| **Microsoft 365 / SharePoint Online** | Dokumentsamarbeid, intranett og kommunikasjon via Teams. Erstatter USB-pinner og private e-postadresser. | [Les mer](https://learn.microsoft.com/nb-no/sharepoint/introduction) |
| **Azure Files** | Fillagring som kan monteres som en nettverksdisk. Tilgjengelig fra alle enheter. | [Les mer](https://learn.microsoft.com/nb-no/azure/storage/files/storage-files-introduction) |
| **Azure Blob Storage** | Lagring av filer, bilder og videoer fra arrangementer. Rimelig og skalerbart. | [Les mer](https://learn.microsoft.com/nb-no/azure/storage/blobs/storage-blobs-overview) |
| **Azure Functions** | Serverless: enkel automatisering av oppgaver, f.eks. sende velkomste-post til nye frivillige. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-functions/functions-overview) |
| **Azure Logic Apps** | Automatisering av arbeidsflyter uten kode. F.eks. "når ny frivillig registreres, opprett bruker og send e-post". | [Les mer](https://learn.microsoft.com/nb-no/azure/logic-apps/logic-apps-overview) |

---

## Bruk av kunstig intelligens (LLM)

Dere oppfordres til å bruke en LLM (f.eks. Claude eller ChatGPT) aktivt underveis i oppgaven for å få rask innsikt i tjenestene. Her er noen eksempler på spørsmål dere kan stille:

> *"Finnes det egne Microsoft-programmer eller rabatter for ideelle organisasjoner, og hva tilbyr de?"*

> *"Hva er Microsoft Entra ID, og hvordan kan det hjelpe en frivillig organisasjon med å håndtere at folk kommer og går?"*

> *"Hva er forskjellen på SharePoint Online og Azure Files – når passer det ene fremfor det andre for dokumentdeling?"*

Bruk LLM til å forstå og diskutere – men vær kritisk og sjekk gjerne svaret mot den offisielle dokumentasjonen (lenkene i tabellen over).