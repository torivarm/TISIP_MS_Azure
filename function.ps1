function New-StudentUser {
  <#
  .SYNOPSIS  Opprett Entra-bruker m/standardpolicy
  #>
  param(
    [Parameter(Mandatory)] [string]$DisplayName,
    [Parameter(Mandatory)] [string]$UserPrincipalName,
    [Parameter(Mandatory)] [string]$MailNickname,
    [Parameter(Mandatory)] [string]$Password
  )

  $pwd = @{ Password = $Password ; ForceChangePasswordNextSignIn = $true }

  try {
    New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
               -MailNickname $MailNickname -AccountEnabled:$true -PasswordProfile $pwd `
               -ErrorAction Stop
  }
  catch { throw "Opprettelse feilet for $UserPrincipalName $($_.Exception.Message)" }
}

function Add-UserToGroup {
  param(
    [Parameter(Mandatory)][string]$UserIdOrUpn,
    [Parameter(Mandatory)][string]$GroupName
  )

  $u = Get-MgUser -UserId $UserIdOrUpn
  $g = Get-MgGroup -Filter "displayName eq '$GroupName'"
  New-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $u.Id
}