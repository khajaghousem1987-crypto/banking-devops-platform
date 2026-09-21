module "development_security_scp" {
  source = "./modules/scp"

  name        = "ProtectSecurityServices"
  description = "Prevents workload accounts from disabling CloudTrail and AWS Config"

 policy_content = file(
  "${path.module}/../policies/scp/deny-disable-security-services.json"
)

  target_ids = [
    module.development_ou.id
  ]
}