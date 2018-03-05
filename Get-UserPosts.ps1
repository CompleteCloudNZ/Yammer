<#
 #  Connects to Yammer via an Application API bearer token
 #  Outputs the users returned
 #
 #  Good resources to review: http://www.nubo.eu/en/blog/
 #>
 
 . .\Yammer-Token.ps1
 $yammerBaseUrl = "https://www.yammer.com/api/v1"

 
$allFrucorUsers = Import-Csv .\ExportedUsers.csv
$numberMessages = 0

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

Function Get-YamMessages($limit, $allMessages, $lastMessageId,$processed) {
    $yammerBatchSize = 20;
    if ($limit -eq $null) {
        $threadLimit = $yammerBatchSize
    }
    else {
        $threadLimit = $limit
    }

    if ($allMessages -eq $null) {
        $allMessages = New-Object System.Collections.ArrayList($null)
    }

    $currentMessageCount = $allMessages.Count;

    if ($currentMessageCount -ge $threadLimit) {
        return $allMessages
    } elseif ($currentMessageCount + $yammerBatchSize -gt $threadLimit) {
        $threadLimit = $threadLimit % $yammerBatchSize;
    } else {
        $threadLimit = $yammerBatchSize
    }

    $urlToCall = "$($yammerBaseUrl)/messages.json"
    $urlToCall += "?limit=" + $threadLimit;
    if ($lastMessageId -ne $null) {
        $urlToCall += "&older_than=" + $lastMessageId;
    }
   
    $headers = Get-BaererToken
    #Write-Host $urlToCall
    
    $webRequest = Invoke-WebRequest -Uri $urlToCall -Method Get -Headers $headers

    if ($webRequest.StatusCode -eq 200) 
    {
        $results = $webRequest.Content | ConvertFrom-Json
        $numberMessages = $processed + $results.messages.Length
        Write-Host $numberMessages "messages processed."
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
    if ($limit -gt 0) {
        $lastMessageId = $results.messages[$results.messages.Length -1].id;
        return Get-YamMessages $limit $allMessages $lastMessageId $numberMessages
    }
    else {
        return $allMessages
    }
}

$messageResults = Get-YamMessages 1000
$messageResults
$messageResults | Select id,privacy,sender_id,client_type,client_url,web_url | Export-Csv .\Exported-Messages.csv -NoTypeInformation
