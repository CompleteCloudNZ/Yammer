. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

#$users = Import-Csv ..\Exports\All-Export-Users.csv

    $urlToCall = "$($yammerBaseUrl)/users.json"

    $userBody = @{ 
        full_name="Shane Vincent (FNZ)"
        email="shane.vincent@frucorsuntory.com"
        summary="Group BT Service Operations Manager"
        job_title="Group BT Service Operations Manager"
        department_name="Business Technology"
        location="86 Plunket Ave"
    }
    $response = Invoke-WebRequest $urlToCall -Method Post -Body $userBody -Headers $headers
    $response
