. ..\Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}


$headers = Get-BaererToken
$groups = import-csv ..\exports\matrix-groups.csv

foreach($group in $groups)
{
    $GroupId = $group.old_id
    $page = 1
    $groupUsers = @()
    if($group.old_id)
    {
        do
        {
            $Uri = $yammerBaseUrl+"/users/in_group/"+$GroupId+".json?page="+$page
            Write-Host ("REST API CALL : $Uri")

            $response = Invoke-WebRequest -Uri $Uri -Method Get -Headers $headers
            $json = $response.Content |ConvertFrom-Json

            $groupUsers += $json.users
            <#
            [xml]$Xml = ((Invoke-WebRequest -Uri $GetMoreGroupsUri -Method Get -Headers $Headers).content)
            $YammerGroups += $Xml.response.users.user
            $Xml.response.users.user
            $GroupCycle ++
            $GroupCount += $Xml.response.users.user.count
            Write-Host ("GROUPMEMBER COUNT : $GroupCount")
            #>
            $page++
        }	
        While ($json.users.count -eq 50)

        $csvfile = "..\exports\groups-users\"+$group.old_id+".csv"
        $groupUsers |export-csv $csvfile -NoTypeInformation
    }
}
