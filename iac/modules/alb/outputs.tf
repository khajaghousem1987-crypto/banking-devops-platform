output "alb_arn" {

  value = aws_lb.banking_alb.arn

}

output "alb_dns_name" {

  value = aws_lb.banking_alb.dns_name

}

output "target_group_arn" {

  value = aws_lb_target_group.banking_tg.arn

}
 