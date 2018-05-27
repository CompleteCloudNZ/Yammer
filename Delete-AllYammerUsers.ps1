. ..\New-Yammer-Token.ps1

$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$headers 

$users = Import-Csv ..\Exports\All-Export-Users.csv

foreach($user in $users)
{
    $webRequest = $null
    $email = $user.name+"@m365x263938.onmicrosoft.com"
    $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$email
    try 
    {
        $webRequest = Invoke-WebRequest -Uri $urlToCall -Headers $headers -Method Get

        $yammeruser = $webRequest.Content | ConvertFrom-Json           
    }
    catch 
    {
        Write-Host $urlToCall "Doesn't exist." -ForegroundColor Yellow
    }

    if($yammeruser.id -gt 10)
    {
        $urlToCall = "$($yammerBaseUrl)/users/$($yammeruser.id)?delete=true"
        $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers
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