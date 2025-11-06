"ab.ola.nordmann@digsec.onmicrosoft.com",
"ab.anna.hansen@digsec.onmicrosoft.com",
"ab.bjorn.olsen@digsec.onmicrosoft.com" |
ForEach-Object {
  $u = Get-MgUser -UserId $_ -ErrorAction SilentlyContinue
  if($u){ Remove-MgUser -UserId $u.Id -Confirm:$false }
}

# Fjern gruppa
$g = Get-MgGroup -Filter "displayName eq 'SG-ab-Helpdesk'"
if($g){ Remove-MgGroup -GroupId $g.Id -Confirm:$false }