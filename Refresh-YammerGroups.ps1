 . ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$page = 1
$raw = @()
$groups = @()
$groupinfo = @()

$groups = import-csv ..\YammerMigration\dest-group-stats.Csv

$headers = Get-BaererToken
# first we need ot discover the groups

foreach($g in $groups)
{
    $g.id
    $g.name

    $x = $Host.ui.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    $x = $Host.ui.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    Write-Host "pressed"


    $urlToCall = "$($yammerBaseUrl)/groups/$($g.id)"
    Write-Host $urlToCall
        $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Delete -Headers $headers
    $webRequest.StatusCode
}

# $groupinfo |Export-Csv ..\YammerMigration\dest-group-stats.Csv -NoTypeInformation

