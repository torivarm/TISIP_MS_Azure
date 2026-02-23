# Finn korrekt SKU for VM-er i din location

Dette scriptet oppretter 3 Ubuntu 22.04-VMer i eksisterende VNets og subnets. Hver VM får en offentlig IP-adresse og plasseres i sitt eget VNet.

> **Forutsetning:** VNets og subnets må være opprettet på forhånd.

---

## Variabler du må sette

```bash
LOCATION="<YOUR-LOCATION>"         # Din Azure-region, f.eks. "norwayeast"
ADMIN_PASSWORD="<YOUR-PASSWORD>"   # Passord for VM-brukeren
VM_SIZE="<YOUR-VM-SIZE>"           # Tilgjengelig VM-størrelse i din region
```

Location er gått igjennom tidligere i en egen gjennomgang.
De neste seksjonene forklarer hvordan du finner riktig verdi for VM_SIZE.

---

## Steg 3 – Finn en tilgjengelig VM-størrelse (VM_SIZE)

Tilgjengelige VM-størrelser varierer mellom regioner og abonnementstyper. Azure for Students har begrensninger på hvilke størrelser som er tilgjengelige, og dette kan variere fra student til student.

### 3a – List tilgjengelige B-serie størrelser

B-serien er de minste og billigste VM-ene, og egner seg godt til testing. Kjør kommandoen under med din region:

```bash
az vm list-skus --location <YOUR-LOCATION> --size Standard_B --output table
```

Eksempel med `switzerlandnorth`:

```bash
az vm list-skus --location switzerlandnorth --size Standard_B --output table
```

Du vil se en tabell med kolonner for navn, tilgjengelighet og eventuelle restriksjoner. Se etter størrelser der kolonnen **Restrictions** er tom – disse er tilgjengelige for ditt abonnement.

### 3b – Filtrer bort størrelser som ikke er tilgjengelige

Noen størrelser vil ha `NotAvailableForSubscription` i Restrictions-kolonnen. For å filtrere disse bort direkte:

```bash
az vm list-skus \
  --location <YOUR-LOCATION> \
  --size Standard_B \
  --query "[?not_null(restrictions)] | [?restrictions[0].reasonCode != 'NotAvailableForSubscription'].name" \
  --output table
```

### 3c – Velg en størrelse

Velg en størrelse fra listen og bruk det eksakte navnet som verdi for `VM_SIZE`. Azure krever alltid `Standard_`-prefikset.

Eksempler på vanlige B-serie størrelser:

| Navn                | vCPU | RAM    |
|---------------------|------|--------|
| `Standard_B1ls`     | 1    | 0.5 GB |
| `Standard_B1s`      | 1    | 1 GB   |
| `Standard_B1ms`     | 1    | 2 GB   |
| `Standard_B2ats_v2` | 2    | 1 GB   |
| `Standard_B2s`      | 2    | 4 GB   |

> **Merk:** Ikke alle disse er nødvendigvis tilgjengelige i din region eller for ditt abonnement. Bruk listen fra kommandoen i steg 3a/3b for å finne hva som faktisk er tilgjengelig for deg.

---

## Steg 4 – Sett passordet (ADMIN_PASSWORD)

Azure krever at passordet oppfyller følgende krav:

- Minst **12 tegn**
- Inneholder **store bokstaver** (A–Z)
- Inneholder **små bokstaver** (a–z)
- Inneholder **tall** (0–9)
- Inneholder **spesialtegn** (f.eks. `_`, `@`, `#`, `%`)

> **Viktig:** Unngå `!` i passordet. Bash tolker `!` som et historieutvidelsestegn inne i doble anførselstegn, noe som kan gi uventede feil.

Eksempel på gyldig passord: `MyS3cure_Pass99`

---

## Steg 5 – Last opp og kjør scriptet i Cloud Shell

### Alternativ A – Last opp filen

1. Klikk på **opplastingsikonet** (pil opp) i Cloud Shell-verktøylinjen
2. Velg `create-vms.sh` fra din lokale maskin
3. Filen lastes opp til hjemmekatalogen din (`~/`)

### Alternativ B – Opprett filen direkte i Cloud Shell

```bash
nano create-vms.sh
```

Lim inn innholdet, sett variablene dine, og lagre med `Ctrl+O` → Enter → `Ctrl+X`.

### Kjør scriptet

```bash
chmod +x create-vms.sh
./create-vms.sh
```

Scriptet vil stoppe med en tydelig feilmelding hvis noen av de tre variablene ikke er satt.

---

## Hva opprettes?

| Ressurs            | Antall | Eksempel på navn             |
|--------------------|--------|------------------------------|
| Virtuelle maskiner | 3      | `vm-demo-norwayeast-001`     |
| Offentlige IP-er   | 3      | `vm-demo-norwayeast-001-pip` |

**OS:** Ubuntu 22.04  
**Brukernavn:** `melling`  
**Autentisering:** Passord  
**Størrelse:** Settes av deg basert på hva som er tilgjengelig i din region

---

## Feilsøking

**`NotAvailableForSubscription`**  
Den valgte VM-størrelsen er ikke tilgjengelig for ditt Azure for Students-abonnement i denne regionen. Gå tilbake til steg 3 og velg en annen størrelse.

**`InvalidParameter – vmSize`**  
Du har glemt `Standard_`-prefikset. Azure krever alltid det fulle navnet, f.eks. `Standard_B2ats_v2`.

**`AuthorizationFailed`**  
Du har ikke tilgang til den valgte regionen. Gå tilbake til steg 2 og velg en annen region.

**Bash-feil ved oppstart av scriptet**  
Sjekk at passordet ditt ikke inneholder `!`. Bytt det ut med et annet spesialtegn.