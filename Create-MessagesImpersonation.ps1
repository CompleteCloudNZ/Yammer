. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

$yammerClientId = "S1K1azXDbHohh28qVvh4Ag"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

Function Get-UserBaererToken($token) {
    $headers = @{ Authorization=("Bearer " + $token) }
    return $headers
}

function Get-UserToken ($UserID) 
{
    $getYammerTokenUrl = "$($yammerBaseUrl)/oauth.json?consumer_key=$($yammerClientId)&user_id=$($UserID)"

    $userBody = @{ 
        user_id    = $UserID
        consumer_key     = $yammerClientId
     }
    
    $yammerResponse2 = Invoke-WebRequest -Uri $getYammerTokenUrl -Body $userBody -Method Post -Headers $headers
    
    $yammerJson2 = $yammerResponse2 | ConvertFrom-Json
    $yammerUserToken = $yammerJson2.token   
    
    return $yammerUserToken
}

function Update-Tags($MessageBody) 
{
    $r = [regex] "\[([^\[]*)\]"
    $tags = $r.Matches($message.body)
    if($tags.Count -eq 0)
    {
        return $MessageBody
    }

    $updatemessage = $MessageBody
    foreach($match in $tags)
    {
        if($match -match "\[user")
        {
            $extractid = $match | Select-String '\d+' | ForEach-Object { $_.Matches[0].Value }
            $buid = ($usermatrix -match $extractid).new_id
            $updatemessage = $updatemessage -replace $extractid,$buid
        }

    }
    return $updatemessage
}

$headers = Get-BaererToken
$usermatrix = import-Csv ..\exports\matrix-users.csv
$groupmatrix = Import-Csv ..\Exports\matrix-groups.csv
#$exportfile = Import-Csv ..\Exports\dataexports\Messagesjan-feb.csv

$mcsv = "..\Uncontrolled\Yammer\Messages.csv"
$fcsv = "..\Uncontrolled\Yammer\Files.csv"

$exportmessages = Import-Csv $mcsv
$exportfiles = Import-Csv $fcsv

$messagematrix = @()

<#

id                      : 1008528666
replied_to_id           :
thread_id               : 1008528666
conversation_id         :
group_id                : 12790260
group_name              : Sales Australia
participants            :
in_private_group        : false
in_private_conversation : false
sender_id               : 1630855955
sender_type             : User
sender_name             : Rhys Pennisi - REP 143 (FAU)
sender_email            : rhys.pennisi@frucor.com
body                    : CBW Express | Melbourne CBD

                          V POS refresh ✅

                          [Tag:22629854:vjanincentive] [[user:1531176302]]
api_url                 : https://www.yammer.com/api/v1/messages/1008528666
attachments             : uploadedfile:116898666
deleted_by_id           :
deleted_by_type         :
created_at              : 2018-01-03T02:31:55.609Z
deleted_at              :


#>

$messagematrixcsv = "..\Exports\matrix-messages.csv"

if (Test-Path $messagematrixcsv)
{
    Write-Host "loadin"
    $matrix = Import-Csv $messagematrixcsv
    
    foreach($line in $matrix)
    {
        $Object = New-Object PSObject -Property @{            
            id              = $line.id               
            old_id          = $line.old_id             
        }               
        $messagematrix += $Object     
    }
}


foreach($message in $exportmessages)
{
    try {
        
        $uid = ($usermatrix -match $message.sender_id).new_id
        $gid = ($groupmatrix -match $message.group_id).new_id
        
        if(!$gid)
        {
            throw "Tried writing to a non-group"
        }

        $messageBody = Update-Tags -MessageBody $message.body

        if($message.replied_to_id -gt 10)
        {
            $rid = $messagematrix |Where-Object {$_.old_id -eq $message.replied_to_id}     

            if(!$rid)
            {
                Write-Error "Tried replying to a non-existent message" -ErrorAction Continue
            }

            $headertemplate = @'
--{0}
Content-Disposition: form-data; name="body""

{1}
--{0}
Content-Disposition: form-data; name="group_id""

{2}
--{0}
Content-Disposition: form-data; name="replied_to_id""

{3}
'@

            $boundary = [guid]::NewGuid().ToString()
            $userBody = $headertemplate -f $boundary, $messageBody, $gid, $rid.id
        }
        else 
        {
            $headertemplate = @'
--{0}
Content-Disposition: form-data; name="body""

{1}
--{0}
Content-Disposition: form-data; name="group_id""

{2}
'@

            $boundary = [guid]::NewGuid().ToString()
            $userBody = $headertemplate -f $boundary, $messageBody, $gid
            
        }

        $usertoken = Get-UserToken -UserID $uid
        $userheaders = Get-UserBaererToken $usertoken

        if($message.attachments)
        {
            # break attachments down to parts if needed
            $attachments = $message.attachments -split ","

            $count = 1

            foreach($attachmentid in $attachments)
            {
                $attachment = $attachmentid | Select-String '\d+' | ForEach-Object { $_.Matches[0].Value }
                $attachment
                $files = $exportfiles |Where-Object {$_.file_id -eq $attachment}
                $files.path
                $path = $files.path -replace "files/","C:\Temp\export-1527410982482\files\"
                $attachmentname = "attachment"+$count.ToString()

                $fileName = Split-Path $path -leaf
                $fileBin = [System.IO.File]::ReadAllBytes($path)
        
                $attachmenttemplate = @'
{0}
--{1}
Content-Disposition: form-data; name="{2}"; filename="{3}"
Content-Type: {4}

{5}
'@
            
                $userBody = $attachmenttemplate -f $userBody, $boundary, $attachmentname, $fileName, $contenttype, $enc.GetString($fileBin)
                $count++
            }

        }

        $footertemplate = @'
    {0}
--{1}--

'@
    
        $Uri = $yammerBaseUrl+"/messages.json"
        $userBody = $footertemplate -f $userBody, $boundary

    
        #$userBody = ConvertTo-Json $userBody
        if($message.attachments)
        {
            #$response = Invoke-RestMethod $target -Headers $headers -Method POST -Body $requestBody -ContentType "multipart/form-data;boundary=$boundary"
            $response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $userheaders -Body $userBody -ContentType "multipart/form-data;boundary=$boundary"

        }
        else 
        {
            $userBody = ConvertTo-Json $userBody
            $response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $userheaders -Body $userBody -UseBasicParsing -ContentType "application/json"

        }

        $json = $response.Content |ConvertFrom-Json
        $json.messages.id
    
        $Object = New-Object PSObject -Property @{            
            id              = $json.messages.id               
            old_id          = $message.id                 
        }               
        $messagematrix += $Object 
    
        $messagematrix |Export-Csv $messagematrixcsv -NoTypeInformation

        # update the messages csv in case we need to start again
        Import-Csv $mcsv | where {$_.id -ne $message.id} | Export-Csv $mcsv -NoTypeInformation
        
    }
    catch {
        $ErrorActionPreference = "Continue"
        $message |Out-File ..\Uncontrolled\Yammer\failure.log -Append
        $_.Exception.Message # |Out-File ..\Uncontrolled\Yammer\failure.log -Append
        $_ |Out-File ..\Uncontrolled\Yammer\failure.log -Append
    }
    #>
}


<# ==============================================================
# 2 – get the user details, esp. the TOKEN

# https://www.yammer.com/api/v1/oauth/tokens.json?consumer_key={0}&user_id={1}
$getYammerTokenUrl = "$($yammerBaseUrl)/oauth.json?consumer_key=$($yammerClientId)&user_id=$($testID)"
$getYammerTokenUrl
$userBody = @{ 
    user_id    = $testID
    consumer_key     = $yammerClientId
 }

$yammerResponse2 = Invoke-WebRequest -Uri $getYammerTokenUrl -Body $userBody -Method Post -Headers $headers

$yammerJson2 = $yammerResponse2 | ConvertFrom-Json
$yammerUserToken = $yammerJson2.token


    


# ==============================================================
# 3 – use the TOKEN from the user

$UserHeaders = @{
    "Authorization" = "Bearer "+$yammerUserToken
    }

    $userBody = @{ 
        user_id    = $testID
        body     = "my first message"
     }
    
$UserHeaders
$userBody

    $Uri = $yammerBaseUrl+"/messages.json"
    Invoke-WebRequest -Uri $Uri -Method Post -Headers $UserHeaders -Body $userBody
    


<#
$userheaders = Get-UserBaererToken $yammerUserToken
$userheaders

$userBody = @{ 
    group_id    = $testGroupID
    user_id     = $testID
    body        = "Of course, you all in BT, know about this already! :)"
 }

$Uri = $yammerBaseUrl+"/messages.json"
Invoke-WebRequest -Uri $Uri -Method Post -Headers $userheaders -Body $userBody

#>

# https://www.yammer.com/api/v1/groups
#$createGroupUrl = "$($yammerBaseUrl)/groups"
#
#$groupBody = @{ name=$NewGroupName; private=’True’; }
#$yammerResponse3 = Invoke-WebRequest –Uri $createGroupUrl –Method Post -Headers $headers -Body $groupBody -usebasicparsing
#
#$yammerXml3 = [xml]$yammerResponse3
#$yammerXml3

#$returnValues = $yammerXml3.response.Id + "|" + $yammerXml3.response.Name

#>