resource "aws_ssm_parameter" "cw_agent_web" {
  description = "Cloudwatch agent config for web servers"
  # name        = "/cloudwatch-agent/config"
  name        = "SystemsManager-CWAgentConfig-Web"
  type        = "String"
  #value       = file("cw_agent_config_web.json")
  value       = file("${path.root}/modules/ssm/cloudwatch_agent_web/cw_agent_config_web.json")
  tags = {
    Creator = "terraform"
  }
}
