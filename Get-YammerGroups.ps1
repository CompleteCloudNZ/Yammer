 . ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$page = 1
$raw = @()
$groups = @()
$groupinfo = @()


$headers = Get-BaererToken
# first we need ot discover the groups

do
{
    $uri = "$($yammerBaseUrl)/groups.json?page="+$page
    $webrequest = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers
    
    $raw = $webrequest.Content |ConvertFrom-Json
    $groups += $raw
    $page++

} while ($raw.Count -gt 0)


foreach($g in $groups)
{
    $Object = New-Object PSObject -Property @{            
        id              = $g.id               
        name            = $g.full_name
        lastmessage     = $g.stats.last_message_at
        members         = $g.stats.members
    }           

    $groupinfo += $Object
}

$groupinfo |Sort-Object lastmessage |Export-Csv ..\Exports\group-stats.Csv

