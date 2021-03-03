Import-Module ActiveDirectory

function createUsers {
    param (
        $nb_user,
        $site
    )
    for ($i=0;$i -lt $nb_user;$i++) {
    $name = "User-$site-$i"
    New-ADUser -Name $name `        -Path "OU=USERS,OU=$site,DC=mtc,DC=com" `        -AccountPassword $(ConvertTo-SecureString -AsPlainText "Admin123" -Force)`        -Enabled $true
    Write-Host $name
    }
}