$messages = Import-Csv .\Exported-Messages.csv
$users = Import-Csv ..\Protected\Frucor-Yammer-Users.csv

$uniquesenders = $messages.sender_id |Group-Object
$userinfo = @()

foreach($senders in $uniquesenders)
{
    $user = $users -match $senders.Name

    $Object = New-Object PSObject -Property @{            
        id              = $user.id               
        email           = $user.email
        name            = $user.name
        location        = $user.location
        job_title       = $user.job_title
        department      = $user.department      
        messages        = $senders.Count
    }               
    $userinfo += $Object    
}

$userinfo |Export-Csv .\Message-Count.csv -NoTypeInformation