param(
    [Parameter(Position=0,mandatory=$true)]
    [string] $bucket_name
)

$backup_bucket_name = $bucket_name + "-backup"

"Fetching thumbnail object keys"
$objects = aws s3api list-objects --bucket $bucket_name --no-paginate --query "Contents[?contains(Key, 'thumbnail')]" | ConvertFrom-Json

##echo $objects
foreach($object in $objects)
{
    "Applying ACL grants"
    $acl = aws s3api get-object-acl --bucket $bucket_name --key $object.key | ConvertFrom-Json
    ##TO DO APply ACL policy to backup object
}
