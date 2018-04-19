 . ..\Yammer-Token.ps1
 $yammerBaseUrl = "https://www.yammer.com/api/v1"

 
$allFrucorUsers = Import-Csv ..\Protected\Frucor-Yammer-Users.csv
$numberMessages = 0

Function Get-BaererToken() 
{
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

Function Get-YamMessages($limit, $allMessages, $lastMessageId,$processed) 
{
    $yammerBatchSize = 20;
    if ($limit -eq $null) 
    {
        $threadLimit = $yammerBatchSize
    }
    else 
    {
        $threadLimit = $limit
    }

    if ($allMessages -eq $null) 
    {
        $allMessages = New-Object System.Collections.ArrayList($null)
    }

    $currentMessageCount = $allMessages.Count;

    if ($currentMessageCount -ge $threadLimit) 
    {
        return $allMessages
    } 
    elseif ($currentMessageCount + $yammerBatchSize -gt $threadLimit) 
    {
        $threadLimit = $threadLimit % $yammerBatchSize;
    } 
    else 
    {
        $threadLimit = $yammerBatchSize
    }

    $urlToCall = "$($yammerBaseUrl)/messages.json"
    $urlToCall += "?limit=" + $threadLimit;
    if ($lastMessageId -ne $null) 
    {
        $urlToCall += "&older_than=" + $lastMessageId;
    }
   
    $headers = Get-BaererToken
    
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers

    if ($webRequest.StatusCode -eq 200) 
    {
        $results = $webRequest.Content | ConvertFrom-Json
        $numberMessages = $processed + $results.messages.Length

        if ($results.messages.Length -eq 0) 
        {
            return $allMessages
        }

        for($x=0;$x -lt $results.messages.Length;$x++)
        {
            if($allFrucorUsers.id -match $results.messages[$x].sender_id)
            {
                $allMessages.Add($results.messages[$x])
            }
        }
    }

    $limit -= $yammerBatchSize
    $comparedate = $results.messages[$results.messages.Length -1].created_at
    if ((Get-Date($comparedate)) -lt ((Get-Date).AddDays(-100))) 
    {
        return $allMessages        
    }
    if ($limit -gt 0) 
    {
        $lastMessageId = $results.messages[$results.messages.Length -1].id;
        return Get-YamMessages $limit $allMessages $lastMessageId $numberMessages
    }
    else 
    {
        return $allMessages
    }
}

$messageResults = Get-YamMessages 65535

$uniquesenders = $messageResults.sender_id |Group-Object
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

$userinfo |Sort-object messages -Descending |Export-Csv ..\Protected\Message-Count.csv -NoTypeInformation