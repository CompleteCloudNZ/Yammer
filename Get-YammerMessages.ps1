. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

$id = "1098779105"

    $urlToCall = "$($yammerBaseUrl)/messages/$($id).json" 
    Write-Host $urlToCall

    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
    $webRequest.Content |ConvertFrom-Json


