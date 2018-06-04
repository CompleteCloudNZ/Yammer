. ..\New-Yammer-Token.ps1

$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$headers 

$users = import-csv ..\YammerMigration\dest-yammer-users-f2.csv


foreach($user in $users)
{

    if($user.id -gt 10)
    {
        $urlToCall = "$($yammerBaseUrl)/users/$($user.id)?delete=true"
        
        $user
        Write-Host $urlToCall
        #$webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers
        if($webRequest.StatusCode -eq 200)
        {
            Write-Host "Deleted " $urlToCall -ForegroundColor Green
        }
        else 
        {
            Write-Host "Failed to Delete " $urlToCall -ForegroundColor Red
        }
    }
}
$users.Count