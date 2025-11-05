$groupName = "SG-App-Helpdesk"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

Import-Csv .\users.csv | ForEach-Object {
  try {
    $pwd = @{ Password = $_.Password ; ForceChangePasswordNextSignIn = $true }

    $u = New-MgUser -DisplayName $_.DisplayName `
                    -UserPrincipalName $_.UPN `
                    -MailNickname $_.MailNickname `
                    -AccountEnabled:$true `
                    -PasswordProfile $pwd `
                    -ErrorAction Stop

    # Legg i gruppe
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $u.Id -ErrorAction Stop

    Write-Host "Opprettet og lagt til: $($_.DisplayName)" -ForegroundColor Green
  }
  catch {
    Write-Host "Feil for $($_.UPN): $($_.Exception.Message)" -ForegroundColor Red
  }
}