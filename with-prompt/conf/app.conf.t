---
to: <%= appname %>/conf/app.conf
force: true
---
<%
 Appname = appname.toUpperCase()
%>
appname = <%= appname %>
httpport = ${<%= Appname %>_HTTP_PORT}
runmode = ${<%= Appname %>_RUNMODE||dev}
autorender = false
copyrequestbody = true
EnableDocs = true

PGuser = ${<%= Appname %>_PGUSER}
PGpass = ${<%= Appname %>_PGPASS}
PGhost = ${<%= Appname %>_PGHOST}
PGport = ${<%= Appname %>_PGPORT}
PGdb   = ${<%= Appname %>_PGDB}
PGschema = ${<%= Appname %>_PGSCHEMA}