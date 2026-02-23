# create-nsg-resources.sh

Dette scriptet oppretter en Resource Group, et Network Security Group (NSG) med en SSH-inbound-regel, samt 3 VNets med 2 subnets hver – der alle subnets knyttes til NSG-en.

---

## Før du kjører scriptet

Kopier scriptet til egen maskin og sett de to variablene øverst:

**1. Din Azure-region**
```bash
LOCATION="<dintillatteregion>"   # Bytt ut med din tillatte region
```

**2. Din offentlige IP-adresse** (brukes til å begrense SSH-tilgang)
```bash
ALLOWED_IP="203.0.113.10"   # Bytt ut med din IP
```
Gå til nettsiden [whatismyip.org](https://www.whatismyip.com)

---

## Hva opprettes?

| Ressurs | Antall | Eksempel på navn |
|---|---|---|
| Resource Group | 1 | `rg-demo-<dintillatteregion>-001` |
| NSG | 1 | `nsg-demo-<dintillatteregion>-001` |
| NSG-regel | 1 | `AllowSSH` (port 22, kun din IP) |
| VNets | 3 | `vnet-demo-<dintillatteregion>-001` |
| Subnets | 6 | `snet-demo-<dintillatteregion>-101` |