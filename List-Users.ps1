<#
 #  Connects to Yammer via an Application API bearer token
 #  Outputs the users returned
 #
 #  Good resources to review: http://www.nubo.eu/en/blog/
 #>
 
 . ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

$allUsers = @()


Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$page = 1

while($allUsers.Count % 50 -eq 0)
{
    $urlToCall = "$($yammerBaseUrl)/users.json"
    $urlToCall += "?page=" + $page;
    
    $headers = Get-BaererToken
    Write-Host $urlToCall
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers

    if ($webRequest.StatusCode -eq 200) {
        $results = $webRequest.Content | ConvertFrom-Json
        if ($results.Length -eq 0) {
            return $allUsers
        }
        foreach($result in $results)
        {
            $Object = New-Object PSObject -Property @{            
                id              = $result.id                 
                full_name       = $result.full_name                 
                job_title       = $result.job_title                 
                url             = $result.url            
                timezone        = $result.timezone
                first_name      = $result.first_name
                last_name       = $result.last_name
                email           = $result.email
            }               
            $allUsers += $Object
        }
    }
    $page++
    #$results
}

$allUsers | Export-Csv .\users.csv