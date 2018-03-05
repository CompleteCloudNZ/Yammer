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

# export the users, by group name, to a CSV

$groups = @("12868771")

foreach($group in $groups)
{
    $GroupId = $group
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


