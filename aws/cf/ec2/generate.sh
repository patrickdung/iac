#!/bin/bash

template_name="1-ec2-web01"
jinja_template=${template_name}.jinja2
output_template=${template_name}.yaml

# Problem with the boolean value/representation between bash and jinja2
# so please use/pass 'true/false' as string from bash to jinja2

region="eun1"
environment="qa"
category="web"
## eun1-dev-web-web01
nodeId=web01
subnetLocation="SubnetPublicWeb1"
# x86_64 or arm64
platformType="arm64"
rootDiskStorageSize="8"
instanceName=${region}-${environment}-${category}-${nodeId}
instanceProfileName="Custom-EC2ToSSM"

jinja2 \
-D region="${region}" \
-D environment="${environment}" \
-D subnetLocation="${subnetLocation}" \
-D platformType=${platformType} \
-D rootDiskStorageSize=${rootDiskStorageSize} \
-D instanceName=${instanceName} \
-D instanceProfileName=${instanceProfileName} \
${jinja_template} -o ${output_template}

cfn-lint --info ${output_template}
