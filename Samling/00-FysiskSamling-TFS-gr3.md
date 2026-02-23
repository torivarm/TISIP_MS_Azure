# Gruppe 2 – Case: Andersen & Partnere AS

## Bedriftsbeskrivelse

Andersen & Partnere er et regnskapskonsulentfirma med 25 ansatte spredt over tre byer. Alle jobber delvis hjemmefra og trenger tilgang til felles dokumenter, klientdata og interne systemer. De har nylig opplevd et phishing-angrep der en ansatt utilsiktet ga fra seg innloggingsdetaljer, noe som satte klientdata i fare.

**Behov:** Sikker og enkel innlogging for alle ansatte uavhengig av hvor de befinner seg, sentral lagring av dokumenter med tilgangsstyring (ikke alle skal se alt), og bedre kontroll over hvem som har tilgang til hva.

**Begrensning:** Ansatte er ikke teknisk anlagte og må oppleve løsningen som enkel å bruke. GDPR stiller krav til hvordan klientdata lagres og behandles.

---

## Oppgave

Design en Azure-løsning for Andersen & Partnere AS. Tegn opp arkitekturen som et enkelt diagram (på papir, whiteboard eller digitalt) og forklar hvilke tjenester dere har valgt og hvorfor. Dere skal presentere løsningen for resten av klassen.

---

## Azure-bibliotek – Relevante tjenester for dette caset

Bruk tabellen nedenfor som utgangspunkt. Dere velger selv hvilke tjenester dere vil inkludere i løsningen – og dere kan godt argumentere for tjenester som ikke står på listen dersom dere mener de passer.

| Tjeneste | Kort beskrivelse | Dokumentasjon |
|---|---|---|
| **Microsoft Entra ID** | Identitets- og tilgangsstyring for brukere og applikasjoner. Håndterer innlogging, roller og tilganger sentralt. | [Les mer](https://learn.microsoft.com/nb-no/entra/identity/fundamentals/whatis) |
| **Azure Multi-Factor Authentication (MFA)** | Krever en ekstra bekreftelse (f.eks. app eller SMS) i tillegg til passord ved innlogging. | [Les mer](https://learn.microsoft.com/nb-no/entra/identity/authentication/concept-mfa-howitworks) |
| **Azure Files** | Fillagring som kan monteres som en nettverksdisk. Erstatter tradisjonell filserver og er tilgjengelig fra alle enheter. | [Les mer](https://learn.microsoft.com/nb-no/azure/storage/files/storage-files-introduction) |
| **Azure Key Vault** | Sikker lagring av passord, tilgangsnøkler og sertifikater. Hindrer at sensitiv informasjon eksponeres. | [Les mer](https://learn.microsoft.com/nb-no/azure/key-vault/general/overview) |
| **Microsoft Defender for Cloud** | Kontinuerlig sikkerhetsvurdering av Azure-miljøet med varsler og anbefalinger ved trusler eller feilkonfigurasjoner. | [Les mer](https://learn.microsoft.com/nb-no/azure/defender-for-cloud/defender-for-cloud-introduction) |
| **Azure Virtual Desktop** | Virtuelt skrivebord som kjører i skyen og er tilgjengelig fra alle enheter med nettleser. | [Les mer](https://learn.microsoft.com/nb-no/azure/virtual-desktop/overview) |
| **Microsoft 365 / SharePoint Online** | Dokumentsamarbeid og kommunikasjon. Kan administreres via Entra ID for sentralisert tilgangsstyring. | [Les mer](https://learn.microsoft.com/nb-no/sharepoint/introduction) |

---

## Bruk av kunstig intelligens (LLM)

Dere oppfordres til å bruke en LLM (f.eks. Claude eller ChatGPT) aktivt underveis i oppgaven for å få rask innsikt i tjenestene. Her er noen eksempler på spørsmål dere kan stille:

> *"Hva er Microsoft Entra ID, og hvordan hjelper det et firma med å styre hvem som har tilgang til hva?"*

> *"Hva er phishing, og hvordan kan Azure MFA beskytte mot denne typen angrep?"*

> *"Hva er forskjellen på Azure Files og Azure Blob Storage når det gjelder dokumentlagring for ansatte?"*

Bruk LLM til å forstå og diskutere – men vær kritisk og sjekk gjerne svaret mot den offisielle dokumentasjonen (lenkene i tabellen over).