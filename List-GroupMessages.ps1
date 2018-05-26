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

$migrategroups = Get-Content .\groups.txt

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

$groupinfo

foreach($grouptomove in $migrategroups)
{
    $GroupIdUpper = $groupinfo -match $grouptomove
    $GroupIdUpper
    $GroupId = $GroupIdUpper.id
    $GroupCycle = 1
    $GroupCount = 0
    $YammerMessages = @()
    $datelimit = $false
    $older_than = 0

    DO
	{
        if($older_than -gt 0)
        {
            $GetMoreGroupsUri = "$($yammerBaseUrl)/messages/in_group/$GroupId.json?older_than=$older_than"
        }
        else 
        {
            $GetMoreGroupsUri = "$($yammerBaseUrl)/messages/in_group/$GroupId.json"
        }
		write-host ("REST API CALL : $GetMoreGroupsUri")
        $json = (Invoke-WebRequest -Uri $GetMoreGroupsUri -Method Get -Headers $Headers).content |ConvertFrom-Json
                
        $YammerMessages += $json.messages 
        $GroupCycle ++
        $GroupCount += $json.messages.Count
        write-host ("GROUPMEMBER COUNT : $GroupCount")
        if((Get-Date $json.messages[$json.messages.Count-1].created_at) -lt (Get-Date "01/01/2018"))
        {
            $datelimit = $true
        }
        else 
        {
            Write-Host $json.messages[$json.messages.Count-1].created_at    
        }
        $older_than = $json.messages[$json.messages.Count-1].id
    }	
    While (($json.messages.Count -gt 0) -and (!$datelimit)) 
    Write-Host "GROUP MESSAGE COUNT" $GroupCount
    $exportname = "..\Exports\"+$grouptomove+".csv"

    $YammerMessages |Export-Csv $exportname -NoTypeInformation 
}
