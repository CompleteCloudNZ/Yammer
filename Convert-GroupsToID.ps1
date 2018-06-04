$fullgroups = Import-Csv ..\YammerMigration\source-group-stats.Csv
$newfullgroups = Import-Csv ..\YammerMigration\dest-group-stats.Csv
$requiredgroups = Import-Csv ..\YammerMigration\Groups.csv

$groups = @()

foreach($group in $requiredgroups)
{
    $groupname = "FRU - "+$group.NewGroupName
    $oldid = $fullgroups |Where-Object {$_.name -eq $group.GroupName}
    $newid = $newfullgroups |Where-Object {$_.name -eq $groupname}

    $Object = New-Object PSObject -Property @{            
        old_name            = $group.GroupName
        new_name            = $groupname
        old_id            = $oldid.id
        new_id              = $newid.id
    }               
    $groups += $Object    
    $object
}

$groups | Export-Csv ..\YammerMigration\matrix=groups.csv -NoTypeInformation