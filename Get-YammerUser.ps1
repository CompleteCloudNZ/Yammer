. ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

# https://www.yammer.com/api/v1/users/1647566075

$userId = "1623049183"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
# $urlToCall = "$($yammerBaseUrl)/users/$($userId)?delete=true"
# Write-Host $urlToCall
# $webRequest = Invoke-WebRequest –Uri $urlToCall –Method Delete -Headers $headers
# $webRequest.StatusCode

$urlToCall = "$($yammerBaseUrl)/users/$($userId).json"

$headers = Get-BaererToken
Write-Host $urlToCall
$webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers

$results = $webRequest.Content | ConvertFrom-Json
$results


#$webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers
