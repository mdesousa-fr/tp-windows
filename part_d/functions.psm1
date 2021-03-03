function GetRandomId {
    param (
        $name,
        $surname
    )

    ($name.Substring(0,1) `
    + $surname.Substring(0,1) `
    + $surname.Substring($surname.Length-1,1) `
    + (Get-Random -Minimum 10000 -Maximum 99999)).ToUpper()
}

function NewADOUFromDistinguishedName {
    param (
        $distinguishedName
    )
    $OU = @()
    for ($i = 1; $i -lt $distinguishedName.Split(',').Count; $i++) {
        $OU += $distinguishedName.Split(',')[$i]
    }
    New-ADOrganizationalUnit `
    -Name ($distinguishedName.Split(",").Split("=")[1]) `
    -Path ($OU -join ",") `
    -ProtectedFromAccidentalDeletion $false
}