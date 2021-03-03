# NIVEAU DE VERBOSITE
$VerbosePreference = "Continue"
# UNITES D'ORGANISATION
$OU_students = "OU=STUDENTS,DC=mtc,DC=com"
$OU_archives = "OU=ARCHIVES,$OU_students"
$OU_teachers = "OU=TEACHERS,DC=mtc,DC=com"
# MOT DE PASSE PAR DEFAUT
$password = "Admin123"
# LISTE DES CSV
$csv_files = Get-ChildItem -Path .\exports