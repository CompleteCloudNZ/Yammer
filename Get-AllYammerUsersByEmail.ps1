. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$userdetails = @()

$headers = Get-BaererToken

$users = import-csv ..\Exports\Bulk-Export-Users.csv

foreach($user in $users)
{

    $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$user.emailaddress

    Write-Host $urlToCall
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
    
    $results = $webRequest.Content | ConvertFrom-Json
    $page++

    foreach($user in $results)
    {
        $Object = New-Object PSObject -Property @{            
            full_name        = $results.full_name
            id               = $results.id
        }               
        $userdetails += $Object    
    }
}

$userdetails |Export-Csv ..\Exports\New-Export-Users.csv -NoTypeInformation
