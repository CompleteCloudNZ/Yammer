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

    foreach($user in $results)
    {
        $Object = New-Object PSObject -Property @{            
            full_name        = $user.full_name
            id               = $user.id
        }
        $users += $Object    
    }

    $results.Count
} while ($results.Count -eq 50)

$users |Export-Csv ..\Exports\New-Export-Users.csv -NoTypeInformation
