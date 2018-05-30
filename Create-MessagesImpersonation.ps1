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

$headers = Get-BaererToken
$usermatrix = import-Csv ..\exports\matrix-users.csv
$groupmatrix = Import-Csv ..\Exports\matrix-groups.csv
$exportfile = Import-Csv ..\Exports\dataexports\Messagesjan-feb.csv

$messagematrix = @()


<# Export file extract

id                      : 1008609639
replied_to_id           : 1004103082
thread_id               : 1004092708
conversation_id         :
group_id                : 12790260
group_name              : Sales Australia
participants            :
in_private_group        : false
in_private_conversation : false
sender_id               : 1531175823
sender_type             : User
sender_name             : Donna McLean (FAU)
sender_email            : donna.mclean@frucor.com
body                    : And a big thank you to my little elf helper [[user:1531176302]] for her awesome shopping and wrapping g skills!! 👌🏼
api_url                 : https://www.yammer.com/api/v1/messages/1008609639
attachments             :
deleted_by_id           :
deleted_by_type         :
created_at              : 2018-01-03T06:19:41.803Z
deleted_at              :

#>

foreach($message in $exportfile)
{
    
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