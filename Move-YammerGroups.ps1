 . ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken
$groups = Import-Csv .\YammerGroups.csv
# first we need ot discover the groups

# POST https://www.yammer.com/api/v1/groups.json?name=new_group_name&private=true

foreach($g in $groups)
{
    if($g.Type -eq "Private")
    {
        $uri = "$($yammerBaseUrl)/groups.json?name="+$g.NewGroupName+"&private=true"
    }
    else 
    {
        $uri = "$($yammerBaseUrl)/groups.json?name="+$g.NewGroupName   
    }
    $webrequest = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers
}