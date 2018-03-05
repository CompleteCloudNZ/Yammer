
$allFrucorUsers = Import-Csv .\ExportedUsers.csv
$allFrucorMessages = Import-Csv .\Exported-Messages.csv

$newexport = @()

foreach($message in $allFrucorMessages)
{
    $user = $allFrucorUsers |where {$_.id -eq $message.sender_id}
    $Object = New-Object PSObject -Property @{            
        user_id         = $user.id                 
        full_name       = $user.name                 
        job_title       = $user.job_title                 
        location        = $user.location
        message_id      = $message.id
        privacy         = $message.privacy
        client_type     = $message.client_type
        web_url         = $message.web_url
    }               
    $newexport += $Object
}

$newexport |Export-Csv .\Yammer-Fulloutput.csv
