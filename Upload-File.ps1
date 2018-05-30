. ..\New-Yammer-Token.ps1
$yammerBaseUrl = "https://www.yammer.com/api/v1"

$yammerClientId = "S1K1azXDbHohh28qVvh4Ag"

Function Get-BaererToken() {
    $headers = @{ Authorization=("Bearer " + $baererToken) }
    return $headers
}


$headers = Get-BaererToken

$gid = "15016709"
$bodystring = "this is a knife party"
$rid = "1096607542"

$InFile = "C:\Temp\export-1527410982482\files\117767609.JPG"
Write-Host "path:" $path


$fileName = Split-Path $InFile -leaf
$boundary = [guid]::NewGuid().ToString()

$fileBin = [System.IO.File]::ReadAllBytes($InFile)
$enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")

$template = @'
--{0}
Content-Disposition: form-data; name="group_id""

{4}
--{0}
Content-Disposition: form-data; name="body""

{5}
--{0}
Content-Disposition: form-data; name="replied_to_id""

{6}
--{0}
Content-Disposition: form-data; name="attachment1"; filename="{1}"
Content-Type: {2}

{3}
--{0}--

'@

$body = $template -f $boundary, $fileName, $ContentType, $enc.GetString($fileBin), $gid, $bodystring, $rid
$Uri = $yammerBaseUrl+"/messages.json"

$body

try
{
    return Invoke-WebRequest -Uri $Uri `
                             -Method Post `
                             -ContentType "multipart/form-data; boundary=$boundary" `
                             -Body $body `
                             -Headers $headers
}
catch [Exception]
{
    $_
}
