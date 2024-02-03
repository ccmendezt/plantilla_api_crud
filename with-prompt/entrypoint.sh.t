---
to: <%= appname %>/entrypoint.sh
force: true
---
<%
 Appname = appname.toUpperCase()
%>
#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ -n "${PARAMETER_STORE:-}" ]; then
  export <%= Appname %>_PGUSER="$(aws ssm get-parameter --name /${PARAMETER_STORE}/<%= appname %>/db/username --output text --query Parameter.Value)"
  export <%= Appname %>_PGPASS="$(aws ssm get-parameter --with-decryption --name /${PARAMETER_STORE}/<%= appname %>/db/password --output text --query Parameter.Value)"
fi

exec ./main "$@"