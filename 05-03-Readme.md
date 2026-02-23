# create-vms.sh

Dette scriptet oppretter 3 Ubuntu 22.04-VMer i eksisterende VNets og subnets. Hver VM får en offentlig IP-adresse og plasseres i sitt eget VNet.

> **Forutsetning:** VNets og subnets må være opprettet på forhånd.

---

## Før du kjører scriptet

Åpne kopier scriptet og sett de to variablene øverst:

**1. Din Azure-region** – må være samme region som VNetene dine ble opprettet i
```bash
LOCATION="<dintillatteregion>"   # Bytt ut med din tillatte region
```

**2. Passord for VM-brukeren**
```bash
ADMIN_PASSWORD="MyS3cure!Pass99"   # Bytt ut med et sikkert passord
```
Azure krever at passordet er minst 12 tegn og inneholder store bokstaver, små bokstaver, tall og spesialtegn.

---

## Kjør scriptet

Kopier inn scriptet i Azure CLI Web.

Scriptet stopper med en feilmelding hvis du har glemt å sette en av variablene.

---

## Hva opprettes?

| Ressurs | Antall | Eksempel på navn |
|---|---|---|
| Virtuelle maskiner | 3 | `vm-demo-<dintillatteregion>-001` |
| Offentlige IP-er | 3 | `vm-demo-<dintillatteregion>-001-pip` |

**VM-spesifikasjoner:** Ubuntu 22.04 · Standard_B1ms (1 vCPU, 2 GB RAM)  
**Brukernavn:** `melling`  
**Autentisering:** Passord