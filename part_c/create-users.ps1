Import-Module ActiveDirectory
Import-Module ".\functions.psm1"

Invoke-Command -ComputerName 'ad1' ` -ScriptBlock ${Function:createUsers} ` -ArgumentList '100','SITE_A' ` -JobName 'Users_SITE_A'

Invoke-Command -ComputerName 'ad3' ` -ScriptBlock ${Function:createUsers} ` -ArgumentList '100','SITE_B' ` -JobName 'Users_SITE_B'

Invoke-Command -ComputerName 'ad5' ` -ScriptBlock ${Function:createUsers} ` -ArgumentList '100','SITE_C' ` -JobName 'Users_SITE_C'

<#
for ($x=0;$x -lt $nb_user;$x++) {
    Remove-ADUser "User-$x" -Confirm:$false
}
#>