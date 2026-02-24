# Gruppe 3 – Case: Midt-Norsk Metallbearbeiding AS

## Bedriftsbeskrivelse

Midt-Norsk Metallbearbeiding har 40 ansatte og produserer deler til offshoreindustrien. De har åtte produksjonsmaskiner som i dag ikke er koblet til noe system – ved feil oppdager de det først når produksjonen stopper. Daglig leder Dagfinn vil ha bedre oversikt over maskinstatus, og ønsker å bli varslet automatisk dersom en maskin oppfører seg unormalt.

**Behov:** Innsamling av data fra maskinene løpende, lagring av dataen over tid for analyse, varsling når verdier er utenfor normale grenser, og en enkel oversikt (dashboard) som produksjonslederen kan følge med på.

**Begrensning:** Maskinene er gamle og kommuniserer via enkle protokoller. IT-budsjettet er ikke stort, og løsningen må være driftssikker – produksjon kan ikke stoppe på grunn av IT-problemer.

---

## Oppgave

Design en Azure-løsning for Midt-Norsk Metallbearbeiding AS. Tegn opp arkitekturen som et enkelt diagram (på papir, whiteboard eller digitalt) og forklar hvilke tjenester dere har valgt og hvorfor. Dere skal presentere løsningen for resten av klassen.

---

## Azure-bibliotek – Relevante tjenester for dette caset

Bruk tabellen nedenfor som utgangspunkt. Dere velger selv hvilke tjenester dere vil inkludere i løsningen – og dere kan godt argumentere for tjenester som ikke står på listen dersom dere mener de passer.

| Tjeneste | Kort beskrivelse | Dokumentasjon |
|---|---|---|
| **Azure IoT Hub** | Tilkobling og administrasjon av IoT-enheter (sensorer, maskiner). Tar imot data fra enheter i sanntid. | [Les mer](https://learn.microsoft.com/nb-no/azure/iot-hub/iot-concepts-and-iot-hub) |
| **Azure Event Hubs** | Strømming og innsamling av store mengder data i sanntid fra mange kilder samtidig. | [Les mer](https://learn.microsoft.com/nb-no/azure/event-hubs/event-hubs-about) |
| **Azure Blob Storage** | Lagring av store mengder data, f.eks. historiske maskindata over tid. Rimelig og skalerbart. | [Les mer](https://learn.microsoft.com/nb-no/azure/storage/blobs/storage-blobs-overview) |
| **Azure Cosmos DB** | Globalt distribuert NoSQL-database. Passer til løpende innsamling av sensordata med høy hastighet. | [Les mer](https://learn.microsoft.com/nb-no/azure/cosmos-db/introduction) |
| **Azure Monitor** | Samler inn og analyserer logger og ytelsesdata. Kan vise maskinstatus i et dashboard. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-monitor/overview) |
| **Azure Alerts** | Definerer regler for varsling – f.eks. send e-post eller SMS dersom en maskinverdi er utenfor normalen. | [Les mer](https://learn.microsoft.com/nb-no/azure/azure-monitor/alerts/alerts-overview) |
| **Azure Logic Apps** | Automatisering av arbeidsflyter uten å skrive kode. F.eks. "når en alarm utløses, send varsel til leder". | [Les mer](https://learn.microsoft.com/nb-no/azure/logic-apps/logic-apps-overview) |

---

## Bruk av kunstig intelligens (LLM)

Dere oppfordres til å bruke en LLM (f.eks. Claude eller ChatGPT) aktivt underveis i oppgaven for å få rask innsikt i tjenestene. Her er noen eksempler på spørsmål dere kan stille:

> *"Hva er IoT, og hva er Azure IoT Hub? Hvordan kobler man en gammel maskin til skyen?"*

> *"Hva er forskjellen på Azure IoT Hub og Azure Event Hubs – når bruker man det ene fremfor det andre?"*

> *"Hva er Azure Logic Apps, og kan det brukes til å sende varsel på e-post når en maskin melder feil?"*

Bruk LLM til å forstå og diskutere – men vær kritisk og sjekk gjerne svaret mot den offisielle dokumentasjonen (lenkene i tabellen over).