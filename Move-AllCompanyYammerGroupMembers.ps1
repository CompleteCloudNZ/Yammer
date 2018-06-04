 . ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$groups = Import-Csv ..\YammerMigration\matrix-groups.csv
$usermatrix = Import-Csv ..\YammerMigration\matrix-users.csv

# first we need ot discover the groups

# POST https://www.yammer.com/api/v1/groups.json?name=new_group_name&private=true

foreach($user in $usermatrix)
{
        $Uri = "$($yammerBaseUrl)/group_memberships.json"
        Write-Host $Uri

        $newid = $user.new_id    
        $userBody = @{ 
            group_id    = "15047737"
            user_id     = $newid
            }

        $response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $userBody
}
