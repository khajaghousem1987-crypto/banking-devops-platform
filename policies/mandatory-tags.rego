package terraform. Tags
 
required_tags := {
    "Project",
    "Environment",
    "Owner"
}
 
taggable := {
    "aws_vpc",
    "aws_subnet",
    "aws_security_group",
    "aws_lb",
    "aws_lb_target_group",
    "aws_cloudwatch_log_group",
    "aws_ecr_repository",
    "aws_iam_role",
    "aws_ecs_cluster"
}
 
deny contains msg if {
 
    resource := input.resource_changes[_]
 
    taggable[resource.type]
 
    tags := resource.change.after.tags
 
    required := required_tags[_]
 
    not tags[required]
 
    msg := sprintf(
        "%s (%s) missing mandatory tag %s",
        [resource.name, resource.type, required]
    )
}