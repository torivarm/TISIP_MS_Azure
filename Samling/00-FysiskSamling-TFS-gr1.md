# Gruppe 1 – Case: Hjertelig Ull AS

## Bedriftsbeskrivelse

Hjertelig Ull AS er en liten garnbutikk i Trondheim med to ansatte. De har frem til nå kun solgt fysisk i butikk, men eieren Marit ønsker å begynne å selge på nett for å nå kunder i hele landet. De har ingen IT-kompetanse internt og trenger en løsning som er enkel å drifte. De har et begrenset budsjett og vil helst unngå å betale for noe de ikke bruker.

**Behov:** En nettbutikk som er tilgjengelig for kunder hele døgnet, lagring av produktbilder, en enkel database over produkter og ordrer, og mulighet for å skalere opp i perioder med mye trafikk (f.eks. jul og påske).

**Begrensning:** Ingen intern IT-avdeling, begrenset budsjett, løsningen må kunne driftes med minimal teknisk kunnskap.

---

## Oppgave

Design en Azure-løsning for Hjertelig Ull AS. Tegn opp arkitekturen som et enkelt diagram (på papir, whiteboard eller digitalt) og forklar hvilke tjenester dere har valgt og hvorfor. Dere skal presentere løsningen for resten av klassen.

---

## Azure-bibliotek – Relevante tjenester for dette caset

Bruk tabellen nedenfor som utgangspunkt. Dere velger selv hvilke tjenester dere vil inkludere i løsningen – og dere kan godt argumentere for tjenester som ikke står på listen dersom dere mener de passer.

| Tjeneste | Kort beskrivelse | Dokumentasjon |
|---|---|---|
| **Azure App Service** | Hostingplattform for nettsider og web-applikasjoner. Ingen serveradministrasjon – du laster opp koden, Azure tar seg av resten. | [Les mer](https://learn.microsoft.com/nb-no/azure/app-service/overview) |
| **Azure Blob Storage** | Lagring av filer, bilder og andre ustrukturerte data. Rimelig og svært skalerbart. | [Les mer](https://learn.microsoft.com/nb-no/azure/storage/blobs/storage-blobs-overview) |
| **Azure SQL Database** | Relasjonsdatabase levert som administrert skytjeneste. Passer til strukturerte data som produkter og ordrer. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-sql/database/sql-database-paas-overview) |
| **Azure CDN** | Leverer innhold (bilder, filer) fra servere nær sluttbrukeren for raskere lastetider. | [Les mer](https://learn.microsoft.com/nb-no/azure/cdn/cdn-overview) |
| **Azure Load Balancer** | Fordeler innkommende trafikk mellom flere servere slik at ingen enkeltserver overbelastes. | [Les mer](https://learn.microsoft.com/nb-no/azure/load-balancer/load-balancer-overview) |
| **Azure Functions** | Serverless: kode som kjøres kun når det skjer noe. Du betaler kun for faktisk bruk. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-functions/functions-overview) |
| **Azure Monitor** | Samler inn og analyserer logger og ytelsesdata fra alle Azure-ressurser. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-monitor/overview) |

---

## Bruk av kunstig intelligens (LLM)

Dere oppfordres til å bruke en LLM (f.eks. Claude eller ChatGPT) aktivt underveis i oppgaven for å få rask innsikt i tjenestene. Her er noen eksempler på spørsmål dere kan stille:

> *"Hva er forskjellen på Azure App Service og Azure Functions, og når bør jeg velge det ene fremfor det andre?"*

> *"Hvordan fungerer Azure Blob Storage, og passer det til lagring av produktbilder i en nettbutikk?"*

> *"Hva menes med skalering i Azure App Service, og hvordan fungerer det i praksis?"*

Bruk LLM til å forstå og diskutere – men vær kritisk og sjekk gjerne svaret mot den offisielle dokumentasjonen (lenkene i tabellen over).