---
sh: 'bee api <%= appname %> -driver=postgres -conn="postgres://<%= pguser %>:<%= pgpass %>@<%= pghost %>/<%= dbname %>?sslmode=disable&search_path=<%= dbschema %>"'
---