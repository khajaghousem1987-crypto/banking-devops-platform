package terraform.tags
 
required_tags := {
    "Project",
    "Environment",
    "Owner"
}
 
deny[msg] {
 
    resource := input.resource_changes[_]
 
    tags := resource.change.after.tags
 
    required := required_tags[_]
 
    not tags[required]
 
    msg := sprintf("%s missing tag %s",
        [resource.name, required])
}