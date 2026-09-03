package terraform.tags
 
required_tags := {
    "Project",
    "Environment",
    "Owner"
}
 
taggable := {
    "aws_vpc"
}
 
deny contains msg if {
 
    resource := input.resource_changes[_]
 
    taggable[resource.type]
 
    tags := resource.change.after.tags_all
 
    required := required_tags[_]
 
    not tags[required]
 
    msg := sprintf(
        "%s (%s) missing mandatory tag %s",
        [resource.name, resource.type, required]
    )
}
