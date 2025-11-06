param(
  [Parameter(Mandatory)][string]$CsvPath,
  [Parameter(Mandatory)][string]$GroupName
)

if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All" | Out-Null
}

# Logging
$logDir = Join-Path (Get-Location) "logs"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
$log = Join-Path $logDir ("bulk-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".txt")
function Write-Log([string]$m){ ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"),$m) | Out-File $log -Append }

# Sørg for at gruppa finnes
$g = Get-MgGroup -Filter "displayName eq '$GroupName'"
if (-not $g) {
  $g = New-MgGroup -DisplayName $GroupName -Description "Opprettet av bulk-skript" `
       -MailEnabled:$false -SecurityEnabled:$true -MailNickname ($GroupName -replace '\s','-').ToLower()
  Write-Log "Opprettet gruppe: $($g.DisplayName) / $($g.Id)"
}

# Behandle CSV
$rows = Import-Csv $CsvPath
foreach($r in $rows){
  try{
    $exists = Get-MgUser -UserId $r.UPN -ErrorAction SilentlyContinue
    if($exists){
      Write-Log "Finnes: $($r.UPN) – hopper opprettelse"
      $msg = Add-UserToGroup -UserIdOrUpn $exists.Id -GroupName $GroupName
      Write-Log $msg
      continue
    }
    $u = New-StudentUser -DisplayName $r.DisplayName -UserPrincipalName $r.UPN -MailNickname $r.MailNickname -Password $r.Password
    Write-Log "Opprettet: $($r.UPN)"
    $msg = Add-UserToGroup -UserIdOrUpn $u.Id -GroupName $GroupName
    Write-Log $msg
  } catch {
    Write-Log "FEIL: $($r.UPN) – $($_.Exception.Message)"
  }
}
Write-Host "Ferdig. Logg: $log" -ForegroundColor Cyan