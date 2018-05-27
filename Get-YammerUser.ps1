. ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

# https://www.yammer.com/api/v1/users/1647566075

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

$urlToCall = "$($yammerBaseUrl)/users/$($userId).json"

$headers = Get-BaererToken
Write-Host $urlToCall
$webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers

$results = $webRequest.Content | ConvertFrom-Json
$results |Export-Csv ..\Exports\Users.csv
