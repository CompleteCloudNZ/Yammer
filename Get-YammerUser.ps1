. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

# https://www.yammer.com/api/v1/users/1647566075

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$users = Import-Csv ..\YammerMigration\source-yammer-users.csv

$userlist = @()

foreach($user in $users)
{
    if(($user.full_name -match "\(FNZ\)") -or ($user.full_name -match "\(FAU\)"))
    {
        $user.full_name = $user.full_name.substring(0,$user.full_name.Length - 6)
    }
    if($user.full_name -match " - ")
    {
        $user.full_name = ($user.full_name -split " - ")[0]
    }
    Write-Host $user.full_name -ForegroundColor Green
    $fname = ($user.full_name -split " ")[0]
    $lnamearr = $user.full_name -split " "

    $lname = ""
    for($x=1; $x -lt $lnamearr.Count; $x++)
    {
        $lname += $lnamearr[$x]
    }

    $fsemail = $fname+"."+$lname+"@frucorsuntory.com"
    $femail = $fname+"."+$lname+"@frucor.com"

    $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$femail

    try {
        $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
        $results = $webRequest.Content | ConvertFrom-Json

        $Object = New-Object PSObject -Property @{            
            id              = $results.id               
            name            = $results.full_name
            job_title       = $results.job_title
            summary         = $results.summary
            activated_at    = $results.activated_at
            department      = $results.department
            email           = $femail
        }           
    
        $userlist += $Object
        
        }
    catch {
        try {
            $urlToCall = "$($yammerBaseUrl)/users/by_email.json?email="+$fsemail
            
            Write-Host "Unable to find" $femail "trying" $fsemail -ForegroundColor Yellow
            $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers
            $results = $webRequest.Content | ConvertFrom-Json
            $Object = New-Object PSObject -Property @{            
                id              = $results.id               
                name            = $results.full_name
                job_title       = $results.job_title
                summary         = $results.summary
                activated_at    = $results.activated_at
                department      = $results.department
                email           = $fsemail
            }           
        
            $userlist += $Object            
            }
        catch {
            Write-Host "Unable to find" $user.full_name -ForegroundColor Red            
        }

    }
    
}

$userlist |export-csv ..\YammerMigration\new-user-export.csv

