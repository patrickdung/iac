#!/bin/bash

template_name="internet-to-web"
jinja_template=${template_name}.jinja2
output_template=${template_name}.yaml

# Problem with the boolean value/representation between bash and jinja2
# so please use/pass 'true/false' as string from bash to jinja2

region="eun1"
environment="qa"
vpcNumber="01"
AllowIngressPortSSH="22"
#AllowIngressPortSSH="-1"
AllowIngressPortHTTP="80"
#AllowIngressPortHTTP="-1"
AllowIngressPortHTTPS="443"
#AllowIngressPortHTTPS="-1"
AllowIngressICMPPing="false"
AllowIngressICMPPing="true"

jinja2 \
-D region="${region}" \
-D environment="${environment}" \
-D vpcNumber="${vpcNumber}" \
-D AllowIngressPortSSH=${AllowIngressPortSSH} \
-D AllowIngressPortHTTP=${AllowIngressPortHTTP} \
-D AllowIngressPortHTTPS=${AllowIngressPortHTTPS} \
-D AllowIngressICMPPing=${AllowIngressICMPPing} \
${jinja_template} -o ${output_template}

cfn-lint --info ${output_template}
