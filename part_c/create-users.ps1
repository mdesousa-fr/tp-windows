Import-Module ActiveDirectory
Import-Module ".\functions.psm1"

Invoke-Command -ComputerName 'ad1' `

Invoke-Command -ComputerName 'ad3' `

Invoke-Command -ComputerName 'ad5' `

<#
for ($x=0;$x -lt $nb_user;$x++) {
    Remove-ADUser "User-$x" -Confirm:$false
}
#>