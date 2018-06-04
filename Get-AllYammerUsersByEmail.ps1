. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$userdetails = @()

$headers = Get-BaererToken

$users = import-csv "C:\Temp\export-1527410982482\messages-all.csv"
$emailaddress = $users |Select-Object sender_email -Unique

foreach($emailuser in $emailaddress)
{
    $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$emailuser.sender_email

    Write-Host $urlToCall
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
    
    $results = $webRequest.Content | ConvertFrom-Json
    $page++

    foreach($user in $results)
    {
        $Object = New-Object PSObject -Property @{            
            full_name        = $user.full_name
            id               = $user.id
            date             = $user.activated_at

        }               
        #$userdetails += $user
        $userdetails += $Object    
        $Object
    }
}

$userdetails |Export-Csv ..\YammerMigration\dest-yammer-users.csv -NoTypeInformation
