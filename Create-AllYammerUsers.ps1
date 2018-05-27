. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}

$headers = Get-BaererToken

$users = Import-Csv ..\Exports\All-Export-Users.csv

foreach($user in $users[0])
{
    $urlToCall = "$($yammerBaseUrl)/users.json"

    $email = $user.name+"@m365x263938.onmicrosoft.com"
    $userBody = @{ 
        full_name=$user.full_name
        email=$email
        summary=$user.summary
        job_title=$user.job_title
        department_name=$user.department
        location=$user.location 
    }
    $response = Invoke-WebRequest $urlToCall -Method Post -Body $userBody -Headers $headers
    $response
}