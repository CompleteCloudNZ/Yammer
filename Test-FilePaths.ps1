$files = import-csv "C:\Temp\export-1527410982482\Files-all.csv"

$files.count
$prefix = "C:\Temp\export-1527410982482\"

foreach($file in $files)
{
    $filepath = $prefix+($file.path -replace "/","\")

    if(!(Test-Path $filepath))
    {
        Write-Host "Unable to find" $filepath -ForegroundColor Red
    }
}