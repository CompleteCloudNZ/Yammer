 . ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$groups = Import-Csv ..\Exports\matrix-groups.csv
$usermatrix = Import-Csv ..\Exports\matrix-users.csv

# first we need ot discover the groups

# POST https://www.yammer.com/api/v1/groups.json?name=new_group_name&private=true

foreach($group in $groups)
{
    $csvfile = "..\exports\groups-users\"+$group.old_id+".csv"
    $users = Import-Csv $csvfile

    foreach($user in $users)
    {
        $user_id = $usermatrix |where {$_.old_id -eq $user.id}
        $Uri = "$($yammerBaseUrl)/group_memberships.json"
        Write-Host $Uri

        $newid = $user_id.new_id    
        $userBody = @{ 
            group_id    = $group.new_id
            user_id     = $newid
         }
         $userBody
         $response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $userBody
    }
}