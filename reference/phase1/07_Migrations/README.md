# 07_Migrations — in-place schema changes

Phase 02 table files are fresh `CREATE`s. They describe the shape a table
**should** have, and they are the only description of it — there are no
migration guards inside them. That is deliberate: a table holds data, so
recreating one is never automatic.

The consequence is that editing a phase 02 file changes nothing on a database
that already has the table. This folder is the other half of the change: the
`ALTER` that brings an existing database up to the shape the phase 02 file now
describes.

**Every change to a table's shape is two edits, in the same commit:**

| edit | file | effect |
|---|---|---|
| 1 | the `02_Tables/**` file | new databases get the new shape |
| 2 | a new file here | existing databases get the new shape |

Miss the first and a fresh deploy loses the change. Miss the second and every
existing database silently drifts. See `CLAUDE.md` at the repo root for the
full rules.

## File naming

```
YYYYMMDD_NN_short-kebab-description.sql

20260915_01_widen-contact-email.sql
20260915_02_add-member-tenure-band.sql
20260922_01_drop-legacy-rpq-variant.sql
```

The name without `.sql` is the `migration_id` recorded in
`Layercake.schema_migration`. Files run in alphabetical order, which for this
format is chronological order. `NN` orders migrations written on the same day.

**Never rename or edit a migration that has been deployed anywhere.** Its name
is its identity in the journal; changing it makes the runner treat it as new
and re-run it. To correct a deployed migration, write another one.

## Writing one

- **One concern per file.** Easier to reason about when one fails halfway.
- **Guard where practical** (`if not exists (select 1 from sys.columns ...)`).
  The journal already stops a second run, but a guarded script is also safe to
  run by hand, and safe when a database is in an unexpected state.
- **Don't reference a later shape.** A migration is read by the database as it
  was at that point in history, not as it is now.
- **Backfill in the same file** as the column you add, unless the backfill is
  long enough to want its own run.
- **Header comment** in the house style: what changes, why, and anything the
  operator needs to know (runtime on a full database, whether a reload is
  needed afterwards).

## How they are applied

`Deploy-Database.ps1` runs this phase last, after `06_Constraints`, and treats
it differently from every other phase:

- **Existing database** (phase 02 did not run, e.g. `-SkipTables`) — files not
  in the journal are executed in order and recorded as `run`.
- **Fresh database** (phase 02 ran in the same invocation) — files are recorded
  as `baseline` **without being executed**. The tables were just built from the
  current phase 02 definitions, so the change is already there.

That second rule is what lets `-Fresh` keep working as this folder grows.
