#!/bin/bash -eux

#sudo hostnamectl set-hostname ${nodename}

# 1. System update
yum -y update
# 2. Upgrade (with --obsolete meaning)
# yum -y upgrade
# 3. Install other useful packages
# yamllint is in EPEL but dependency is not resolved
yum install -y tmux git jq tree telnet
# 4. CW Agent
if [ `/bin/uname -m` == "x86_64" ];then
  arch="amd64"
fi
if [ `/bin/uname -m` == "arch64" ];then
  arch="arm64"
fi
rpm -Uvh https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/$arch/latest/amazon-cloudwatch-agent.rpm

mkdir -p /usr/share/collectd/
touch /usr/share/collectd/types.db
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${ssm_cloudwatch_config} -s
##/opt/aws/bin/cfn-init -v --stack AWS::StackId --resource EC2Instance --region AWS::Region --configsets default /opt/aws/bin/cfn-signal -e $? --stack AWS::StackId --resource EC2Instance --region AWS::Region

echo "POC of web-to-db connection" >> /tmp/script.sh
echo "${db_user}:${db_pass}@tcp(${db_endpoint})/${connect_to_db_name}" >> /tmp/script.sh
