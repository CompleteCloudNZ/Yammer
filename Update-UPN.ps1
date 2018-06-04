if(!$credential)
{
    $credential = Get-Credential
}


Connect-MsolService

$group1 = "#O365Lic_E1_003_Frucor"
$group2 = "#O365Lic_E3_002_Frucor"
$soureupn = "@frucor.com"
$destinationupn = "@frucorsuntory.com"
$tempupn = "@suntorygroup.onmicrosoft.com"

$groups = Get-ADGroupMember $group1
$groups += Get-ADGroupMember $group2

foreach($user in $groups[0])
{
    $fulldeets = Get-ADUser $user.SamAccountName -properties *

    $mailname = ($fulldeets.EmailAddress -split "@")[0]
    $mailname

    $newupn = $mailname+$destinationupn
    $oldupn = $mailname+$soureupn
    $transpupn = $mailname+$tempupn
    Get-ADUser $fulldeets.SamAccountName |Set-ADUser -UserPrincipalName $newupn
    Get-ADUser $fulldeets.SamAccountName -Server wnzakldc1.frucor.local |Set-ADUser -UserPrincipalName $newupn
    
    Set-MsolUserPrincipalName -UserPrincipalName $oldupn -NewUserPrincipalName $transpupn
    Set-MsolUserPrincipalName -UserPrincipalName $transupn -NewUserPrincipalName $newupn
}