$oldusers = Import-Csv ..\Exports\Old-Users.csv
$newnewser = Import-Csv ..\Exports\New-Export-Users.csv

$usermatrix = @()

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
}

$usermatrix | Export-Csv ..\Exports\matrix-users.csv -NoTypeInformation