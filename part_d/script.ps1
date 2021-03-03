# >>> MODULES <<< #
Import-Module ActiveDirectory
Import-Module .\functions.psm1

# >>> VARIABLES <<< #
. .\vars.ps1

# >>> EXECUTION <<< #
# CREATION DE L'OU STUDENTS
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_students'") {
    Write-Verbose "[OU] $OU_students already exists"
}
else {
    try {
        NewADOUFromDistinguishedName $OU_students
        Write-Verbose "[OU] $OU_students created"
    }
    catch {
        Write-Verbose "[OU] An Error occured during creation of $OU_students"
    }
}
# CREATION DE L'OU ARCHIVE
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_archives'") {
    Write-Verbose "[OU] OU_archives already exists"
}
else {
    try {
        NewADOUFromDistinguishedName $OU_archives
        Write-Verbose "[OU] $OU_archives created"
    }
    catch {
        Write-Verbose "[OU] An Error occured during creation of $OU_archives"
    }
}
# CREATION DE L'OU TEACHERS
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU_teachers'") {
    Write-Verbose "[OU] $OU_teachers already exists"
}
else {
    try {
        NewADOUFromDistinguishedName $OU_teachers
        Write-Verbose "[OU] $OU_teachers created"
    }
    catch {
        Write-Verbose "[OU] An Error occured during creation of $OU_teachers"
    }
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
                try {
                    New-ADUser `
                    -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -GivenName $($import[$b].PRENOM) `
                    -Surname $($import[$b].NOM) `
                    -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -SamAccountName $(GetRandomId $import[$b].PRENOM $import[$b].NOM) `
                    -Path $OU_teachers `
                    -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                    -Enabled $true
                    Write-Verbose "[USER] '$($import[$b].PRENOM) $($import[$b].NOM)' created"
                }
                catch {
                    Write-Verbose "[USER] An Error occured during creation of '$($import[$b].PRENOM) $($import[$b].NOM)'"                    
                }
            }
        }
        $import = $null
    }
    # LISTE D'ETUDIANTS
    else {
        Write-Verbose "[CSV] Import students list"
        Write-Verbose "[CSV] File : $($csv_files[$a].FullName)"
        $import = Import-Csv $csv_files[$a].FullName
        Write-Verbose "[AD] Import existing students"
        $ad_import = Get-ADUser -filter * -SearchBase $OU_students
        # VERIFICATION SI L'ETUDIANT EXISTE DANS L'AD
        for ($i = 0; $i -lt $ad_import.Count; $i++) {
            if ($import.IDENTIFIANT.Contains($ad_import[$i].SamAccountName)) {
                Write-Verbose "[USER] '$($ad_import[$i].SamAccountName)' already exists"
            }
            else {
                try {
                    ### ARCHIVAGE ###
                    Move-ADObject -Identity ($ad_import[$i].distinguishedName) -TargetPath $OU_archives
                    Write-Verbose "[ARCHIVE] '$($ad_import[$i].SamAccountName)' archived"
                }
                catch {
                    Write-Verbose "[ARCHIVE] An Error occured during the archiving of '$($ad_import[$i].SamAccountName)'"
                }
            }
        }
        # AJOUT DES NOUVEAUX ETUDIANTS
        if (!($ad_import)) {
            Write-Verbose "[AD] First run"
            for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
                try {
                    New-ADUser `
                    -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -GivenName $($import[$b].PRENOM) `
                    -Surname $($import[$b].NOM) `
                    -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `
                    -SamAccountName $($import[$b].IDENTIFIANT) `
                    -Path $OU_students `
                    -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                    -OtherAttributes @{
                    'departmentNumber'="$($import[$b].IDENTIFIANT)";
                    'msDS-cloudExtensionAttribute1'="$($import[$b].'DATE NAISSANCE')" 
                    } `
                    -Enabled $true
                    Write-Verbose "[USER] '$($import[$b].PRENOM) $($import[$b].NOM)' created"
                }
                catch {
                    Write-Verbose $_
                    Write-Verbose "[USER] An Error occured during creation of '$($import[$b].PRENOM) $($import[$b].NOM)'"
                }
            }
            $import = $null
        }
        else {
            for ( $b=0 ; $b -lt $import.Count ; $b++ ) {
                if ($ad_import.SamAccountName.Contains($import[$b].IDENTIFIANT)) {
                    Write-Verbose "[USER] '$($import[$b].IDENTIFIANT)' already exists"
                }
                else {
                    try {
                        New-ADUser `
                        -Name "$($import[$b].PRENOM) $($import[$b].NOM)" `
                        -GivenName $($import[$b].PRENOM) `
                        -Surname $($import[$b].NOM) `
                        -DisplayName "$($import[$b].PRENOM) $($import[$b].NOM)" `
                        -SamAccountName $($import[$b].IDENTIFIANT) `
                        -Path $OU_students `
                        -AccountPassword $(ConvertTo-SecureString -AsPlainText $password -Force) `
                        -OtherAttributes @{
                        'departmentNumber'="$($import[$b].IDENTIFIANT)";
                        'msDS-cloudExtensionAttribute1'="$($import[$b].'DATE NAISSANCE')" 
                        } `
                        -Enabled $true
                        Write-Verbose "[USER] '$($import[$b].PRENOM) $($import[$b].NOM)' created"
                    }
                    catch {
                        Write-Verbose "[USER] An Error occured during creation of '$($import[$b].PRENOM) $($import[$b].NOM)'"                    
                    }
                }
            }
            $import = $null
        }
    }
}

