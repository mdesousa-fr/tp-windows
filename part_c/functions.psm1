﻿Import-Module ActiveDirectory

function createUsers {
    param (
        $nb_user,
        $site
    )
    for ($i=0;$i -lt $nb_user;$i++) {
    $name = "User-$site-$i"
    New-ADUser -Name $name `
    Write-Host $name
    }
}