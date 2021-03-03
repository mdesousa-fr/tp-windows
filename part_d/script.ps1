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

    $name.Substring(0,1) `    + $surname.Substring(0,1) `    + $surname.Substring($surname.Length-1,1) `    + (Get-Random -Minimum 10000 -Maximum 99999)
}

#===========#
# EXECUTION #
#===========#
# CREATION DES OU
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_students'") {
    Write-Verbose "[INFO] $OU_students already exists"
}
else {
    New-ADOrganizationalUnit `    -Name ($OU_students.Split(",").Split("=")[1]) `    -Path ($OU_students.Split(",")[1,2] -join ",") `    -ProtectedFromAccidentalDeletion $false
}
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_teachers'") {
    Write-Verbose "[INFO] $OU_teachers already exists"
}
else {
    New-ADOrganizationalUnit `    -Name ($OU_teachers.Split(",").Split("=")[1]) `    -Path ($OU_teachers.Split(",")[1,2] -join ",") `    -ProtectedFromAccidentalDeletion $false
}

# CREATION DES COMPTES
for ( $a=0 ; $a -lt $csv_files.Count ; $a++ ) {
    # LISTE DE PROFS
    if ($csv_files[$a].Name.Contains("prof")) {
        Write-Verbose "[INFO] Import d'une liste de professeurs"
        Write-Verbose "[INFO] Fichier : $($csv_files[$a].FullName)"
        $import = Import-Csv $csv_files[$a].FullName
        for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
            New-ADUser `                -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `                -GivenName $($import[$b].PRENOM) `                -Surname $($import[$b].NOM) `                -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `                -SamAccountName $(Get-RandomId $import[$b].PRENOM $import[$b].NOM) `                -Path $OU_teachers `                -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                -Enabled $true
        }
        $import = $null
    }
    # LISTE D'ETUDIANTS
    else {
        $school_year = $csv_files[$a].Name.Split(".")[0]
        Write-Verbose "[INFO] Création de l'OU pour l'année $school_year"
        if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq 'OU=$school_year,$OU_students'") {
            Write-Verbose "[INFO] OU=$school_year,$OU_students already exists"
        }
        else {
            New-ADOrganizationalUnit `            -Name ($school_year) `            -Path ($OU_students) `            -ProtectedFromAccidentalDeletion $false
        }
        Write-Verbose "[INFO] Import d'une liste d'étudiants"
        Write-Verbose "[INFO] Fichier : $($csv_files[$a].FullName)"
        $import = Import-Csv $csv_files[$a].FullName
        for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
            New-ADUser `                -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `                -GivenName $($import[$b].PRENOM) `                -Surname $($import[$b].NOM) `                -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `                -SamAccountName $($import[$b].IDENTIFIANT) `                -Path "OU=$school_year,$OU_students" `                -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                -OtherAttributes @{
                   'departmentNumber'="$($import[$b].IDENTIFIANT)";
                   'msDS-cloudExtensionAttribute1'="$($import[$b].'DATE NAISSANCE')" 
                } `
                -Enabled $true
        }
        $import = $null
    }
}

