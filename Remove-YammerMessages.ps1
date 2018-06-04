. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

$messages = Import-Csv ..\YammerMigration\matrix-messages.csv

foreach($message in $messages)
{
    $urlToCall = "$($yammerBaseUrl)/messages/$($message.id)" 
    Write-Host $urlToCall

    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers
    $webRequest
}

