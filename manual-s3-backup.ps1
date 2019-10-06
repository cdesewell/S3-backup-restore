param(
    [Parameter(Position=0,mandatory=$true)]
    [string] $bucket_name
)

$backup_bucket_name = $bucket_name + "-backup"

"Performing sync from " + $bucket_name + " to " + $backup_bucket_name
aws s3 sync s3://$bucket_name s3://$backup_bucket_name --source-region eu-west-1 --region eu-central-1 