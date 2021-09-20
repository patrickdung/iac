#!/bin/bash

jinja_template=01-vpc.jinja2
output_template=01-vpc.yaml

# Problem with the boolean value/representation between bash andjinja2
# so please use/pass 'true/false' as string from bash to jinja2

region="eun1"
environment="qa"
#environment="dev"
vpcNumber="01"
#vpcNumber="02"
vpcCIDR="10.23.0.0/16"
#vpcCIDR="10.21.0.0/16"
# For AWS, min subnet mask is /28 for subnets
# This template creates 12 subnets, max subnet mask is now /20
cidrCount="12"
subnetMask="24"
# cidrBits in AWS terms, https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-cidr.html
cidrBits=$((32-${subnetMask}))
createNatGW="false"

#jinja2 ${jinja_template} -o ${output_template}

##jinja2 \
##-D region="eun1" \
##-D environment="stg" \
##-D vpcNumber="02" \
##-D createNatGW="false" \

jinja2 \
-D region="${region}" \
-D environment="${environment}" \
-D vpcNumber="${vpcNumber}" \
-D vpcCIDR="${vpcCIDR}" \
-D cidrCount="${cidrCount}" \
-D cidrBits="${cidrBits}" \
-D createNatGW="${createNatGW}" \
${jinja_template} -o ${output_template}

cfn-lint --info ${output_template}
