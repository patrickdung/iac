#!/bin/bash

template_name="pgsql"
jinja_template=${template_name}.jinja2
output_template=${template_name}.yaml

# Problem with the boolean value/representation between bash and jinja2
# so please use/pass 'true/false' as string from bash to jinja2

region="eun1"
environment="qa"
category="rds"
## eun1-dev-rds-db01
dataBaseId=db01
engineVersion="13.2"
password="initialPassword"
multiAZ="false"
allocatedStorage="6"
# ResourceName in CF has to be alpha numeric only
rdsResourceName=RDS${dataBaseId}
rdsInstanceName=${region}-${environment}-${category}-${dataBaseId}

jinja2 \
-D region="${region}" \
-D environment="${environment}" \
-D engineVersion="${engineVersion}" \
-D password="${password}" \
-D multiAZ="${multiAZ}" \
-D allocatedStorage="${allocatedStorage}" \
-D rdsResourceName=${rdsResourceName} \
-D rdsInstanceName=${rdsInstanceName} \
${jinja_template} -o ${output_template}

cfn-lint --info ${output_template}
