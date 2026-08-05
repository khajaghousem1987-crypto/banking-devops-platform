package terraform.s3
 
deny contains msg if {
 
    resource := input.resource_changes[_]
 
    resource.type == "aws_s3_bucket"
 
    resource.change.after.acl == "public-read"
 
    msg := sprintf("Bucket %s is public",

        [resource.name])

} 