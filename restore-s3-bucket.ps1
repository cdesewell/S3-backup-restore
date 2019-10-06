param(
    [Parameter(Position=0,mandatory=$true)]
    [string] $bucket_name
)

$account_no = $(aws sts get-caller-identity --output text --query 'Account')

##Re-create origional Bucket
aws s3 mb s3://$bucket_name --region eu-west-1

##Enable Versioning on new bucket
aws s3api put-bucket-versioning --bucket $bucket_name --versioning-configuration Status=Enabled

##Restore Objects from backup
aws s3 sync s3://$bucket_name-backup s3://$bucket_name --source-region eu-central-1 --region eu-west-1

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
            ""Bucket"": ""arn:aws:s3:::$($bucket_name)-backup""
        }
    }]
}
"@

##Apply Role to new bucket
aws s3api put-bucket-replication --bucket $bucket_name --replication-configuration $role

