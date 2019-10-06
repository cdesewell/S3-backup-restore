param(
    [Parameter(Position=0,mandatory=$true)]
    [string] $bucket_name
)

$backup_bucket_name = $bucket_name + "-backup"

"Enabling versioning for bucket " + $bucket_name
aws s3api put-bucket-versioning --bucket $bucket_name --versioning-configuration Status=Enabled

"Creating backup bucket " + $backup_bucket_name
aws s3 mb s3://$backup_bucket_name --region eu-central-1

"Enabling versioning for backup bucket " + $backup_bucket_name
aws s3api put-bucket-versioning --bucket $backup_bucket_name --versioning-configuration Status=Enabled

$account_no = $(aws sts get-caller-identity --output text --query 'Account')

##Define Cross Region Replication role
$role = @"
{
    ""Role"": ""arn:aws:iam::$($account_no):role/s3-replication-role"", ""Rules"": [
    {
        ""Status"": ""Enabled"", 
        ""Priority"": 1, 
        ""DeleteMarkerReplication"": { ""Status"": ""Disabled"" },
        ""Filter"" : { ""Prefix"": """"}, 
        ""Destination"": {
            ""Bucket"": ""arn:aws:s3:::$($backup_bucket_name)""
        }
    }]
}
"@

"Enabling replication from "+ $bucket_name +" to " + $backup_bucket_name
aws s3api put-bucket-replication --bucket $bucket_name --replication-configuration $role