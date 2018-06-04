$oldusers = Import-Csv ..\YammerMigration\source-yammer-users.csv
$newnewser = Import-Csv ..\YammerMigration\dest-yammer-users.csv

$usermatrix = @()
$count = $oldusers.Count

foreach($user in $newnewser)
{
    $oldid = $oldusers |Where-Object {$_.full_name -eq $user.full_name}
    $newid = $newnewser |Where-Object {$_.full_name -eq $user.full_name}

    if($newid.count -gt 1)
    {
        $newid = $newid[0]
    }
    $Object = New-Object PSObject -Property @{            
        name                = $user.full_name
        old_id              = $oldid.id
        new_id              = $newid.id
    }               
    $usermatrix += $Object    
    Write-Host $count
    $count--
}

$usermatrix | Export-Csv ..\YammerMigration\matrix-users.csv -NoTypeInformation