package terraform. Tags
 
required_tags := {
    "Project",
    "Environment",
    "Owner"
}
 
deny contains msg if {
 
    resource := input.resource_changes[_]
 
    tags := resource.change.after.tags
 
    required := required_tags[_]
 
    not tags[required]
 
    msg := sprintf("%s missing mandatory tag %s",
        [resource.name, required])
}