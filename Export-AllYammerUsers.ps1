. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$page = 1
$users = @()

$headers = Get-BaererToken

do 
{
    $urlToCall = "$($yammerBaseUrl)/users.json?page="+$page

    $headers = Get-BaererToken
    Write-Host $urlToCall
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
    
    $results = $webRequest.Content | ConvertFrom-Json
    $page++
    $results[0]

    exit

    foreach($user in $results)
    {
            $Object = New-Object PSObject -Property @{            
                full_name        = $user.full_name
                id               = $user.id
                email            = $user.email
            }
            $users += $Object    
            $Object    
    }

    $results.Count
} while ($results.Count -eq 50)

$users |Export-Csv ..\YammerMigration\dest-yammer-users.csv -NoTypeInformation
