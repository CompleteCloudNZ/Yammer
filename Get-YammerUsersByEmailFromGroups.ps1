. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$userdetails = @()
<#

$location = "..\YammerMigration\Group-Admins"
$dir = get-childitem $location

$allusers = @()

foreach($file in $dir)
{
    $fullpath = $location+"\"+$file
    $csv = import-csv $fullpath

    foreach($item in $csv)
    {
        $Object = New-Object PSObject -Property @{            
            full_name        = $item.full_name
            email            = $item.email
        }  
        $allusers += $Object          
    }
}

$users = import-csv "C:\Temp\export-1527410982482\messages-all.csv"
$emailaddress = $users |Select-Object sender_name, sender_email -Unique

foreach($u in $emailaddress)
{
    $fullpath = $location+"\"+$file
    $csv = import-csv $fullpath

    foreach($item in $csv)
    {
        $Object = New-Object PSObject -Property @{            
            full_name        = $item.sender_name
            email            = $item.sender_email
        }  
        $allusers += $Object          
    }
}


$allusers |export-csv tempusers.csv

exit

#>

$headers = Get-BaererToken

$users = import-csv "..\YammerMigration\tempusers.csv"
#$emailaddress = $users |Select-Object sender_email -Unique

foreach($emailuser in $users)
{
    $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$emailuser.email

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
            state            = $user.state

        }               
        #$userdetails += $user
        $userdetails += $Object    
        $Object
    }
}

$userdetails |Export-Csv ..\YammerMigration\dest-yammer-users-f2.csv -NoTypeInformation
