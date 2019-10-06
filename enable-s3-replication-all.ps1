param(
    [Parameter(Position=0,mandatory=$true)]
    [string] $bucket_search
)

$buckets = (aws s3api list-buckets --query "Buckets[].Name") | Where-Object {$_ -match $bucket_search}

$replication_script = $PSScriptRoot+"\enable-s3-replication.ps1"

foreach ($bucket in $buckets)
{
    $bucket = $bucket -replace ",", ""
    $bucket = $bucket -replace '"', ''
    
    if($bucket -notmatch "backup")
    {
        & $replication_script -bucket_name $bucket.Trim()
    }
}