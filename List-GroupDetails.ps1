<#
 #  Connects to Yammer via an Application API bearer token
 #  Outputs the users returned
 #
 #  Good resources to review: http://www.nubo.eu/en/blog/
 #>
 
 . ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$page = 1

$raw = @()
$groups = @()

# first we need ot discover the groups

do
{
    $uri = "https://www.yammer.com/api/v1/groups.json?page="+$page
    $webrequest = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers
    
    $raw = $webrequest.Content |ConvertFrom-Json
    $groups += $raw
    $page++

} while ($raw.Count -gt 0)

$groups |Select-Object full_name
$groupinfo = @()

foreach($group in $groups)
{
    $GroupId = $group.id

    $uri = "https://www.yammer.com/api/v1/groups/"+$GroupId+"/members.json"
    write-host ("REST API CALL : $uri")

    $results = (Invoke-WebRequest -Uri $uri -Method Get -Headers $Headers).Content
    $array = $results |ConvertFrom-Json

    $groupadmins = $array.users |Where-Object {$_.is_group_admin -eq "True"}

    $Object = New-Object PSObject -Property @{            
        id              = $GroupId               
        full_name       = $array.group.full_name                 
        admins          = $groupadmins.email -join ";"            
        description     = $array.group.description
        members         = $array.total_members
    }               
    $groupinfo += $Object    
}

$exportname = ".\Groups\groupadmins.csv"
$groupinfo |Export-Csv $exportname -NoTypeInformation 

exit
foreach($group in $groups)
{
    $GroupId = $group.id
    $GroupCycle = 1
    $GroupCount = 0
    $YammerGroups = @()

    DO
	{
		$GetMoreGroupsUri = "https://www.yammer.com/api/v1/users/in_group/$GroupId.json?page=$GroupCycle"
		write-host ("REST API CALL : $GetMoreGroupsUri")
        [xml]$Xml = ((Invoke-WebRequest -Uri $GetMoreGroupsUri -Method Get -Headers $Headers).content)
        $YammerGroups += $Xml.response.users.user
        $GroupCycle ++
        $GroupCount += $Xml.response.users.user.count
		write-host ("GROUPMEMBER COUNT : $GroupCount")
    }	
	While ($Xml.response.users.user.count -gt 0)
    $xml.response |gm
    $exportname = ".\Groups\"+$group.full_name.replace(" ","_")+".csv"

    $YammerGroups | Select-Object id,full-name,email |Export-Csv $exportname -NoTypeInformation 
}




