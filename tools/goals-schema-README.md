# EDGEx Goals Schema

Run these files in Supabase SQL Editor in order:

1. `goals-schema-part-01-core.sql`
2. `goals-schema-part-02-metrics.sql`
3. `goals-schema-part-03-sprints.sql`
4. `goals-schema-part-04-security.sql`

If a part fails, stop there and fix that error before continuing. Each part is safe to rerun.

`goals-schema-part-04-security.sql` grants access to authenticated users only. The current Goals tables are still single-user tables, so this protects against anonymous access but is not per-user isolation.
