#=========#
# MODULES #
#=========#
Import-Module ActiveDirectory

#===========#
# VARIABLES #
#===========#
# NIVEAU DE VERBOSITE
$VerbosePreference = "Continue"
# UNITES D'ORGANISATION
$OU_students = "OU=Students,DC=mtc,DC=com"
$OU_teachers = "OU=Teachers,DC=mtc,DC=com"
# MOT DE PASSE PAR DEFAUT
$password = "Admin123"
# LISTE DES CSV
$csv_files = Get-ChildItem -Path .\exports

#===========#
# FUNCTIONS #
#===========#
function Get-RandomId {
    param (
        $name,
        $surname
    )

    ($name.Substring(0,1) `
    + $surname.Substring(0,1) `
    + $surname.Substring($surname.Length-1,1) `
    + (Get-Random -Minimum 10000 -Maximum 99999)).ToUpper()
}

#===========#
# EXECUTION #
#===========#
# CREATION DES OU
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_students'") {
    Write-Verbose "[OU] $OU_students already exists"
}
else {
    Write-Verbose "[OU] $OU_students created"
    New-ADOrganizationalUnit `
    -Name ($OU_students.Split(",").Split("=")[1]) `
    -Path ($OU_students.Split(",")[1,2] -join ",") `
    -ProtectedFromAccidentalDeletion $false
}
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq 'OU=ARCHIVE,$OU_students'") {
    Write-Verbose "[OU] OU=ARCHIVE,$OU_students already exists"
}
else {
    Write-Verbose "[OU] 'OU=ARCHIVE,$OU_students' created"
    New-ADOrganizationalUnit `
    -Name "ARCHIVE" `
    -Path ($OU_students) `
    -ProtectedFromAccidentalDeletion $false
}

if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_teachers'") {
    Write-Verbose "[OU] $OU_teachers already exists"
}
else {
    Write-Verbose "[OU] $OU_teachers already exists"
    New-ADOrganizationalUnit `
    -Name ($OU_teachers.Split(",").Split("=")[1]) `
    -Path ($OU_teachers.Split(",")[1,2] -join ",") `
    -ProtectedFromAccidentalDeletion $false
}

# CREATION DES COMPTES
for ( $a=0 ; $a -lt $csv_files.Count ; $a++ ) {
    # LISTE DE PROFS
    if ($csv_files[$a].Name.Contains("prof")) {
        Write-Verbose "[CSV] Import teachers list"
        Write-Verbose "[CSV] File : $($csv_files[$a].FullName)"
        $import = Import-Csv $csv_files[$a].FullName
        for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
            if (Get-ADUser -Filter "Name -eq '$($import[$b].PRENOM) $($import[$b].NOM)'" ) {
                Write-Verbose "[USER] '$($import[$b].PRENOM) $($import[$b].NOM)' already exists"
            }
            else {
                Write-Verbose "[USER] Create user '$($import[$b].PRENOM) $($import[$b].NOM)'"
                New-ADUser `
                    -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -GivenName $($import[$b].PRENOM) `
                    -Surname $($import[$b].NOM) `
                    -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -SamAccountName $(Get-RandomId $import[$b].PRENOM $import[$b].NOM) `
                    -Path $OU_teachers `
                    -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                    -Enabled $true  
            }
        }
        $import = $null
    }
    # LISTE D'ETUDIANTS
    # else {
    #     Write-Verbose "[CSV] Import d'une liste d'étudiants"
    #     Write-Verbose "[CSV] Fichier : $($csv_files[$a].FullName)"
    #     $import = Import-Csv $csv_files[$a].FullName
    #     for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
    #         New-ADUser `
    #             -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `
    #             -GivenName $($import[$b].PRENOM) `
    #             -Surname $($import[$b].NOM) `
    #             -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `
    #             -SamAccountName $($import[$b].IDENTIFIANT) `
    #             -Path "OU=$school_year,$OU_students" `
    #             -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
    #             -OtherAttributes @{
    #                'departmentNumber'="$($import[$b].IDENTIFIANT)";
    #                'msDS-cloudExtensionAttribute1'="$($import[$b].'DATE NAISSANCE')" 
    #             } `
    #             -Enabled $true
    #     }
    #     $import = $null
    # }
}

