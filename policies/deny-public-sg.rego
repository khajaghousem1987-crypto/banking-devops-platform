package terraform.security
 
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
 
    ingress := resource.change.after.ingress[_]
 
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    ingress.from_port == 22
 
    msg := sprintf("Security Group %s allows SSH from Internet", [resource.name])
}
 
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
 
    ingress := resource.change.after.ingress[_]
 
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    ingress.from_port == 3389
 
    msg := sprintf("Security Group %s allows RDP from Internet", [resource.name])
}