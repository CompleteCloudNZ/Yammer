$fullgroups = Import-Csv ..\Exports\group-stats.Csv
$newfullgroups = Import-Csv ..\Exports\new-group-stats.Csv
$requiredgroups = Import-Csv .\YammerGroups.csv

$groups = @()

foreach($group in $requiredgroups)
{
    $oldid = $fullgroups |Where-Object {$_.name -eq $group.GroupName}
    $newid = $newfullgroups |Where-Object {$_.name -eq $group.NewGroupName}

    $Object = New-Object PSObject -Property @{            
        old_name            = $group.GroupName
        new_name            = $group.NewGroupName
        old_id            = $oldid.id
        new_id              = $newid.id
    }               
    $groups += $Object    
}

$groups | Export-Csv ..\Exports\matrix-groups.csv