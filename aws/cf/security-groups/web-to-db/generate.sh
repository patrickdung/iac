#!/bin/bash

template_name="web-to-db"
jinja_template=${template_name}.jinja2
output_template=${template_name}.yaml

# Problem with the boolean value/representation between bash and jinja2
# so please use/pass 'true/false' as string from bash to jinja2

region="eun1"
environment="qa"
vpcNumber="01"

jinja2 \
-D region="${region}" \
-D environment="${environment}" \
-D vpcNumber="${vpcNumber}" \
${jinja_template} -o ${output_template}

cfn-lint --info ${output_template}
