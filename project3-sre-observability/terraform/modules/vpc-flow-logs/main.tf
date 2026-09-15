resource "aws_cloudwatch_log_group" "flow" { name="/banking/${var.name_prefix}/vpc-flow-logs" retention_in_days=var.log_retention_days }
data "aws_iam_policy_document" "assume" { statement { effect="Allow" principals { type="Service" identifiers=["vpc-flow-logs.amazonaws.com"] } actions=["sts:AssumeRole"] } }
resource "aws_iam_role" "flow" { name="${var.name_prefix}-vpc-flow-logs-role" assume_role_policy=data.aws_iam_policy_document.assume.json }
data "aws_iam_policy_document" "policy" { statement { effect="Allow" actions=["logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogGroups","logs:DescribeLogStreams"] resources=["${aws_cloudwatch_log_group.flow.arn}:*"] } }
resource "aws_iam_role_policy" "flow" { name="${var.name_prefix}-vpc-flow-logs" role=aws_iam_role.flow.id policy=data.aws_iam_policy_document.policy.json }
resource "aws_flow_log" "this" { iam_role_arn=aws_iam_role.flow.arn log_destination=aws_cloudwatch_log_group.flow.arn traffic_type="ALL" vpc_id=var.vpc_id }
