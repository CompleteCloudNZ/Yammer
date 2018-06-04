. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

$emailuser = "timdfd.bell@frucor.com
"


$urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$emailuser
Write-Host $urlToCall

try {
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
    $results = $webRequest.Content | ConvertFrom-Json
    $results
    
    $userId = $results.id
    $userId
    
    $urlToCall = "$($yammerBaseUrl)/users/$($userId).json?delete=true"
    Write-Host $urlToCall
    }
catch {
    Write-Host "Unable to find user"
}
#$webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers