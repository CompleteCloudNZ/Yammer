 . ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$groups = Import-Csv ..\YammerMigration\matrix-groups.csv

foreach($group in $groups)
{
    $csvfile = "..\YammerMigration\group-admins\"+$group.old_id+".csv"
    $users = Import-Csv $csvfile
    $admins = @()

    foreach($user in $users)
    {
        if($user.is_group_admin -eq "TRUE")
        {
            Write-Host $user.full_name "is an admin in group" $group.new_id "old id" $group.old_id -ForegroundColor Yellow

        }

    }
    Write-Host
}
