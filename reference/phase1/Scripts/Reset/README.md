# Reset scripts

Two destructive scripts for clearing a **test** database down to a fresh start.
Neither is deployed — `Deploy-Database.ps1` only walks the numbered phase
folders, so everything under `Scripts/` is skipped by a normal deploy. They run
only when you ask for them by name, or via the `-Reset` / `-Fresh` options on
the deploy runner.

| Script | Drops objects? | Deletes data? | Use when |
|---|---|---|---|
| `teardown-all.sql` | Yes — everything in the schema, and the schema | Yes | The shape has changed. Follow with a full deploy |
| `reset-data.sql` | No | Yes — every table, plus every identity rewound | The shape is fine, you just want to re-run the load from zero |

Both touch **only the Layercake schema**. The `CE` / `Subs` source views the
bronze loaders read are never modified.

## Via the deploy runner

```powershell
# the full round trip: drop the schema, then redeploy every phase
.\Deploy-Database.ps1 -Fresh

# drop everything and stop (redeploy later, or from a different branch)
.\Deploy-Database.ps1 -Reset Objects

# keep the objects, throw away every row, reload the seed rows
.\Deploy-Database.ps1 -Reset Data

# show the plan without touching anything
.\Deploy-Database.ps1 -Fresh -List
```

You are asked to type the database name before anything is destroyed. `-Force`
skips that prompt for unattended runs.

`-Reset` on its own resets and stops. Add `-Phase` / `-Filter` to deploy a
subset afterwards, or `-Fresh` for a full deploy.

## By hand

```
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i teardown-all.sql -b -N -I
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i reset-data.sql   -b -N -I
```

Each has a `@whatif` knob at the top of the file — set it to `1` to print the
statements it would run and change nothing.

## teardown-all.sql

Discovery is dynamic, so it drops whatever is actually in the schema — objects
added since the script was written, and half-finished state left behind by a
failed deploy. Drop order:

1. Foreign keys, in both directions — an FK anywhere in the database pointing at
   a Layercake table would block the table drop
2. Views
3. Procedures
4. Tables — after the procedures, so a schemabound function used by a constraint
   is no longer referenced
5. Functions, aggregates, sequences, synonyms, user-defined types
6. The schema itself, which only drops once it is empty

There is no wrapping transaction. If a drop fails part way through, fix the
cause and run it again: the script rediscovers what is left, so it is safe to
re-run and finishes the job.

The deploy journal `Layercake.schema_migration` goes with everything else. The
deploy that follows recreates it in phase 02 and re-baselines it in phase 07 —
every migration recorded as `baseline`, none executed, because the tables were
just built from definitions that already contain those changes.

Afterwards the database is blank as far as this project is concerned, which is
the state phase 02 needs: table scripts are fresh `CREATE`s and fail on a
database that already has the tables. Every other phase is re-runnable, so if
only the procedures, indexes or foreign keys have changed you do not need a
teardown at all — `.\Deploy-Database.ps1 -SkipTables` redeploys them over the
live database and keeps the data.

## reset-data.sql

Leaves every object in place and empties it. The pipeline ends up in the same
state as a freshly deployed blank database, so the next

```sql
exec Layercake.usp_run_daily_load;
```

is a full historical backfill again.

What that clears, beyond the obvious:

- the bronze snapshots — the next bronze load inserts rather than diff-syncs;
- `etl_daily_count_loaded`, the per-date checkpoint. Without clearing this the
  silver daily-count walk skips every date it has already marked, and you would
  get an empty rebuild rather than a backfill;
- `etl_run_log` / `etl_progress_log` / `etl_daily_count_pending_rebuild`, so the
  run history starts clean;
- the three `recon_*` diagnostic tables;
- `ref_enrolment_exception`, the gap-fill for the migration-gap contacts. Since
  20260928_02 phase 03 no longer re-seeds it: the **next silver load**
  re-captures it, from bronze under the current rules, via
  `Layercake.usp_load_ref_enrolment_exception`. So it comes back derived as at
  that run rather than restored to the original snapshot, and any manual edits
  made to those rows are lost.

**One table is exempt: `Layercake.schema_migration`.** This reset leaves every
object in place, so the tables keep whatever shape their migrations gave them,
and the journal that records those migrations has to survive to match. Clear it
and the next deploy would try to re-apply every migration against tables that
already have the change. Use `-Reset Objects` / `-Fresh` when you want the
journal gone too — that rebuilds and re-baselines it.

**Seed rows go too**, so phase 03 has to be reloaded afterwards or the id-0
`N/A` members are missing and the gold loads cannot resolve their keys.
`-Reset Data` does this for you; by hand it is:

```powershell
.\Deploy-Database.ps1 -Phase 03
```

Mechanics worth knowing:

- Every foreign key is disabled first and re-enabled `WITH CHECK` at the end, so
  clearing order does not matter and the FKs stay **trusted** afterwards.
- Tables nothing references are `TRUNCATE`d. The dimensions and reference tables
  that facts point at are `DELETE`d instead — `TRUNCATE` is not allowed on an FK
  target even with the constraint disabled — and their identity is rewound to
  the original seed with `DBCC CHECKIDENT`, so the reloaded seed rows get the
  same ids they would on a blank database.
