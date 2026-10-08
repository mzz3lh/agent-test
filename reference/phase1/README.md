# Layercake RICS — database project

Complete, self-contained definition of the Layercake warehouse: every table,
key, index, constraint, seed row and stored procedure. Deploying this folder to
a blank database gives you a working pipeline — nothing else is needed.

```
database/
├── 01_Security/           1 file    schema
├── 02_Tables/            49 files   one file per table, with its keys and intrinsic indexes
│   ├── Control/           6         ETL run log, progress log, load tracking, deploy journal
│   ├── Bronze/            9         raw 1:1 landing tables
│   ├── Silver/           20         reference, config and derived tables
│   ├── Gold/             12         star schema (9 dims, 3 facts)
│   └── Reconciliation/    3         diagnostic tables written by the recon report
├── 03_SeedData/           2 files   static reference rows (the enrolment-exception capture here is retired — it moved into silver)
├── 04_Programmability/   47 files   one file per procedure or view
│   ├── Views/             2         vw_enrolment_base - the qualifying enrolment/election rules
│   │                                vw_student_superseded - Students who moved on to a qualifying enrolment
│   └── StoredProcedures/
│       ├── Control/       5         logging, progress, watch, retro-change helper
│       ├── Bronze/        9         one loader per bronze table
│       ├── Silver/       15         one loader per silver table
│       ├── Gold/         12         one loader per gold table
│       └── Orchestration/ 4         usp_load_bronze / _silver / _gold / usp_run_daily_load
├── 05_Indexes/            3 files   performance indexes, by layer
├── 06_Constraints/        2 files   foreign keys, by layer
├── 07_Migrations/         5 files   in-place ALTERs for databases that
│                                    already exist; journalled, run once each
├── Scripts/                         ad hoc scripts — NOT deployed
│   ├── Debugging/         4 files   single-contact and payment drill-downs
│   ├── Maintenance/       1 file    insert-only top-up of ref_enrolment_exception (superseded — the load does it)
│   ├── Reconciliation/    4 files   active/paid difference lists, pipeline
│   │                                and contact-level reconciliation
│   └── Reset/             3 files   teardown / data reset / truncate for test databases
├── Deploy-Database.ps1              ordered sqlcmd deployment
└── README.md
```

104 deployable SQL files, one object each, plus any migrations under
`07_Migrations/` and twelve ad hoc scripts under `Scripts/`. The deploy runner only
walks folders matching `NN_`, so everything in `Scripts/` is skipped
automatically. Within phase 04 it walks
`StoredProcedures/` before `Views/` (alphabetical), though order does not
matter there — procedures resolve their dependencies at run time.

## Deploying

```powershell
# blank database - full deploy
.\Deploy-Database.ps1 -Server myserver.database.windows.net -Database LayercakeRICS -User deploy

# preview the ordered file list without connecting
.\Deploy-Database.ps1 -List

# redeploy just the stored procedures over an existing database
.\Deploy-Database.ps1 -Phase 04

# redeploy everything except the tables over an existing database
.\Deploy-Database.ps1 -SkipTables

# one module and its table
.\Deploy-Database.ps1 -Filter brnz_contact

# pending migrations only
.\Deploy-Database.ps1 -Phase 07
```

`-SkipTables` is the routine rollout: it brings every re-runnable phase back
into line with the files and then applies any migration this database has not
seen. See **Changing a table's shape** below.

Connection details fall back to `RICS_SQL_SERVER` / `RICS_SQL_DATABASE` /
`RICS_SQL_USER` / `RICS_SQL_PASSWORD`; the password is prompted for securely if
not supplied. Then:

```sql
exec Layercake.usp_run_daily_load;   -- first run is the full historical backfill
```

## Clearing down for a fresh start

Testing options on the same runner. **Test databases only** — both destroy data,
and you are asked to type the database name before anything happens (`-Force`
skips the prompt for unattended runs).

```powershell
# the full round trip: drop the whole schema, then redeploy every phase
.\Deploy-Database.ps1 -Fresh

# drop every Layercake object and the schema, then stop
.\Deploy-Database.ps1 -Reset Objects

# keep the objects, empty every table, rewind every identity, reload phase 03
.\Deploy-Database.ps1 -Reset Data

# show the plan without touching the database
.\Deploy-Database.ps1 -Fresh -List
```

`-Reset Objects` when the shape has changed, `-Reset Data` when it has not and
you only want the next `usp_run_daily_load` to be a full backfill again. The
data reset clears `etl_daily_count_loaded` along with everything else — without
that the silver daily-count walk would skip every date it has already marked.

It also clears `ref_enrolment_exception`. That table is no longer re-seeded by
phase 03 — the next silver load re-captures it from scratch under the current
rules, which is exactly what a live database's load does incrementally. See
**The enrolment exceptions** below.

Both are driven by the scripts in `Scripts/Reset/`, which touch nothing outside
the Layercake schema and can also be run by hand; see that folder's README.

## Phase order, and why it is safe

| Phase | Contents | Notes |
|---|---|---|
| 01 | `create schema Layercake` | Created only if missing |
| 02 | Tables | No table script references another, so alphabetical order works. **The one phase that is not re-runnable** |
| 03 | Seed data | Must precede any load: the id-0 `N/A` members are what make every fact key resolve. `seed-enrolment-exception.sql` here is a retired no-op — `ref_enrolment_exception` is maintained by the silver load |
| 04 | Stored procedures | `CREATE OR ALTER`; dependencies resolve at run time, not create time |
| 05 | Performance indexes | Optional; cheapest to build after the first full load. Dropped and rebuilt each deploy |
| 06 | Foreign keys | `WITH CHECK`, so they are TRUSTED; validate instantly on empty tables. Dropped and re-added each deploy |
| 07 | Migrations | In-place `ALTER`s for databases that already exist. Journalled in `Layercake.schema_migration`, so each runs at most once per database. Runs last |

Foreign keys are a separate phase rather than inline on the tables. That is what
makes phase 02 order-independent, and it preserves the original design intent:
indexes and FKs are cheapest to apply *after* the first full load, so on a
rebuild-with-data you can deploy 01–04, load, then run 05 and 06.

## Script conventions

**Everything that can be rebuilt without losing data is re-runnable.** Deploying
the same files twice is not an error, and the second pass leaves the database
matching the files rather than skipping past whatever is already there:

- `01_Security` creates the schema only if `schema_id('Layercake')` is null.
- `03_SeedData` guards every insert. It is DML, not DDL, and a second run must
  not duplicate the gender or status lists. `seed-enrolment-exception.sql` is a
  **retired no-op** — that capture moved into the silver load, see
  **The enrolment exceptions** below.
- `04_Programmability` uses `CREATE OR ALTER` throughout — one procedure or
  view per file, and it is the first statement in the file. `-Phase 04` is
  the normal way to ship a logic change.
- `05_Indexes` and `06_Constraints` `drop ... if exists` before each `create` /
  `add constraint`. Editing a definition there is therefore enough to change it
  on the next deploy — nothing goes stale. The cost is that a redeploy against a
  loaded database rebuilds those indexes and revalidates those foreign keys
  instead of skipping them.

**Table scripts are the exception: they are fresh `CREATE`s** and will fail on a
database that already has them. That is deliberate — a table holds data, so
recreating it is never something a deploy should do on its own, and an
accidental deploy over a live database stops loudly at phase 02 instead of
touching anything. There are no migration guards
either — every incremental patch, add-column step and table-copy-and-rename
rebuild from the project's history is already folded into these definitions, and
anything that changes them from here on is a migration under `07_Migrations/`.

To redeploy over a live database, skip that phase:

```powershell
# schema, seed rows, procedures, indexes and FKs brought back into line;
# tables and their data untouched
.\Deploy-Database.ps1 -SkipTables
```

If the table shapes themselves have changed, the migration that accompanies the
change brings the live tables up to the new shape in the same run — see below.
`-Fresh` (teardown plus full deploy) remains available for test databases, but
it costs a full backfill and is not the route for a database holding real data.

## Changing a table's shape

Phase 02 files are fresh `CREATE`s with no migration guards, so editing one has
no effect on a database that already has the table. **Every shape change is
therefore two edits, in the same commit:**

| edit | file | who it fixes |
|---|---|---|
| 1 | the `02_Tables/**` file | new databases get the new shape |
| 2 | a new file in `07_Migrations/` | existing databases get the new shape |

Miss the first and the next `-Fresh` silently loses the change. Miss the second
and every existing database drifts. `07_Migrations/README.md` covers the file
format and how to write one; the rules are restated in `CLAUDE.md` at the repo
root.

`Layercake.schema_migration` is the journal — one row per migration this
database has accounted for. The runner picks its mode automatically:

- **APPLY** — phase 02 did not run (e.g. `-SkipTables`), so the tables are at
  their old shape. Migrations missing from the journal are executed in file
  order and recorded as `run`.
- **BASELINE** — phase 02 ran in the same invocation, so the tables were just
  built from the current definitions and already have the change. Migrations are
  recorded as `baseline` **without being executed**.

Baseline is what keeps `-Fresh` working as the folder grows: without it, a
migration that adds a column would run against a table created with that column
already present, and fail.

`-Reset Data` deliberately leaves `schema_migration` alone — it empties data,
and the journal is a fact about shape, not about rows. `-Reset Objects` /
`-Fresh` drop it with everything else, and the deploy that follows rebuilds and
re-baselines it.

`-SkipMigrations` leaves phase 07 out entirely, for shipping a code-only change:

```powershell
.\Deploy-Database.ps1 -SkipTables -SkipMigrations
```

**Each table file carries its own keys and intrinsic indexes** — the primary
key, unique constraints, checks, defaults, and any index that is part of the
table's key design (for example `ux_silv_membership_events_nk`, or the unique
clustered star grain on `fact_daily_member_count_detail`). Only pure performance
indexes live in phase 05.

## How the pipeline fits together

Bronze lands each source object 1:1 with soft-delete audit columns. Silver
derives reference data, membership events, per-day state ranges and the daily
counts. Gold is the Power BI star schema. Every layer is a re-derive plus a
diff-sync, so re-running the load is always the recovery action — there is no
manual cleanup step.

One procedure per target table, plus four orchestrators that call them in
dependency order. Every module takes an optional `@run_id` and generates one if
omitted, so any single table can be rebuilt on its own and still be traceable in
`Layercake.etl_run_log`:

```sql
-- reload one bronze table after a source fix
exec Layercake.usp_load_brnz_subs_status;

-- tie several targeted modules into one traceable run
declare @rid uniqueidentifier = newid();
exec Layercake.usp_load_silv_member_base       @run_id = @rid;
exec Layercake.usp_load_silv_membership_events @run_id = @rid;
```

`Layercake.silv_member_base` is the per-contact base that the membership-events,
data-anomaly, member-profile and annual-rate-base modules all read. It exists
because those four consumers previously shared a `#temp` table inside one large
procedure, and a temp table cannot cross a procedure boundary.

Its driver excludes four cohorts: test records, Student grade (unless the Student
status is superseded in the enrolment history — see `vw_student_superseded`
below), contacts with no `brnz_rics_record` row, and contacts with no
`brnz_cust_trans` row at all. The
last two are excluded because there is no membership record / no transaction
history behind them, and each is reported back as a `silv_data_anomaly` type
(`NO_RICS_RECORD`, `NO_TRANSACTIONS`) rather than silently dropped. Both tests
are repeated on the payment-derived Readmission in module 9 — the only event
that can open a state range without a member-base row. Nothing extra is needed
on the paid side: the daily paid count joins the same state ranges as the active
count, so an excluded contact is counted as neither.

A fifth exclusion sits in module 9 rather than the driver: **a Join event
(Candidate or RPQ) requires a valid payment.** The contact must hold at least one
paid invoice position in `Subs.vwSubsMemberStatuses` — read through
`silv_payment_events`, so the paid-position list is defined once — in any
campaign year. A contact who has never paid stays in `silv_member_base` (its
Lapse, and a Candidate's Change, are still derived) but gets no Join, so no
state range opens on its enrolment or election date. Readmission and Renewal
need no separate test: both are derived from `silv_payment_events`, so the
payment is there by construction — and for those two it is the paid position for
**that campaign year**, since the row is keyed on (contact, campaign year). A
member who paid last year and not yet this year is still active (only a Lapse
closes the state range) but has no Renewal for this year until this year's paid
position appears. The withheld Joins are reported as `JOIN_NO_PAYMENT`.

The **07 fallback** referred to below is the curated gap-fill in
`ref_enrolment_exception`, coalesced in per date wherever the real enrolment rows
supply nothing — see **The enrolment exceptions**.

One correction sits in the driver alongside the 07 fallback: **an enrolment date
recorded in a later campaign year than the contact's first paid position is
backdated to that first paid year.** Some contacts hold a valid, qualifying
enrolment row dated years after the subs history says they were paying. Derived
as recorded, the Join landed in a year they had not paid (and counted them as
paid from the Join event there) while the earlier payments fell through as
Renewals before any Join. `usp_load_silv_member_base` now moves the enrolment
date to the first paid year, using the payment event's date in that year, so the
Join lands where the paying started and every later paid year derives as a
Renewal. The recorded date is kept on the row (`recorded_enrolment_date`,
flagged by `enrolment_from_subs_history`) and the cohort is reported as
`ENROLMENT_AFTER_FIRST_PAID`. A contact with **no enrolment date** gets the same
treatment on its election date, since the election is then the Join anchor (a
Join/RPQ, or the Change that opens the range); that cohort is reported as
`ELECTION_AFTER_FIRST_PAID`. Where an enrolment date exists the election is never
moved. A contact lapse that falls between the first paid year and the recorded
date now stands as a real Lapse rather than being treated as stale.

The same correction runs **forward**: a contact with a valid enrolment in a
campaign year they hold no paid position for, whose first paid position is a
later year, has the enrolment date moved forward to that first paid year — the
first paid year is the join year, and only the years after it renew. This one is
**bounded by the payment history**. `silv_payment_events` only reaches back as
far as the subs history that was loaded (CY2022 at the time of writing), so for
anyone who enrolled before that, "first paid year" is the edge of the data, not
a fact about the member; unbounded, the rule would move every long-standing
member's Join into the first loaded year. A date is only moved forward where its
recorded campaign year is on or after the earliest campaign year in
`silv_payment_events` (logged each run by `usp_load_silv_member_base`). Reported
as `ENROLMENT_BEFORE_FIRST_PAID`, and `ELECTION_BEFORE_FIRST_PAID` for a contact
with no enrolment date. That second type also covers the one case where an
election moves although an enrolment exists: the enrolment moved forward *past*
the recorded election, so the election is carried to the same join date —
otherwise the Change would precede the Join, open the state range in the unpaid
year, and the Join would then drop the member back to Candidate. A contact lapse
before the new join date is treated as stale, like any lapse that predates the
Join.

`Layercake.vw_enrolment_base` holds the valid-enrolment and election rules —
the route allowlist, the application-type exclusions, the 14-day cool-off. It is
a shared view because two modules need the identical test: module 8 derives the
dates from it, and module 10 uses it to decide whether an excluded contact
nevertheless had a valid enrolment or election. A view rather than a function:
it takes no parameters, and the deployment account on the client database has no
rights to create functions.

`Layercake.vw_student_superseded` is the driver's one override of the Student
exclusion. The rics-record grade can be stale: a Student application is closed
and an APC or Associate enrolment opened — typically minutes apart on the same
day — while the record still says Student. The view names the contacts whose
most recently created Student application is ended and has a qualifying
`vw_enrolment_base` row created on or after it (ordered on `[Created DateTime]`,
because the two rows share a date). The driver keeps those contacts despite the
grade; a Student row created after the qualifying one, or still open, does not
override. Shared for the same reason as `vw_enrolment_base`: module 10 and the
reconciliation scripts apply the identical test.

`Layercake.silv_daily_count` is the one module that loads two tables
(`silv_daily_count` and `silv_daily_count_detail`). Per chunk it rebuilds the
detail, re-derives the main table as a SUM of that same detail, and marks the
dates loaded — all in one transaction. That atomicity is what lets a failed run
resume, so the two are deliberately not split.

## The enrolment exceptions

`Layercake.ref_enrolment_exception` holds gap-fill enrolment / election dates
for contacts who have been **paying** members but have no qualifying row on the
enrolments table — a migration-era cohort with no enrolment row at all, and a
larger one whose rows exist but fail the rules in `vw_enrolment_base`.

It matters more than "a missing date" suggests. Without a qualifying row *and*
without an exception row, `silv_member_base` gives the contact a null enrolment
date **and** a null election date; both Join branches in
`silv_membership_events` need one of those; no Join means no state range; and
the active count and *both* paid counts are gated by the state-range join. So
the contact is in none of them. With an exception row, they count.

**`usp_load_ref_enrolment_exception` (silver module 8a) is the only writer.** It
runs on every silver load, between `silv_payment_events` (which supplies the
driver — the paid subs invoice positions, already the pipeline's single
definition of "paid") and `silv_member_base` (which coalesces the result in).
Before that it was a phase 03 seed guarded on the table being empty, which left
a live database frozen on its first capture while a `-Fresh` / `-Reset Data`
rebuild re-derived against current source. The two disagreed on the most recent
day's counts, by a small and slowly growing amount.

The lifecycle is deliberately asymmetric:

| | behaviour | why |
|---|---|---|
| **Capture** | insert-only | a contact captured once keeps the dates their history was built on — no run moves a date a count already used |
| **New capture** | logs `etl_daily_count_pending_rebuild` under `enrol_exception` | the derived date is usually years old, so it reaches into already-loaded dates. Today corrects itself; history moves only on `@RebuildFrom` |
| **Supersession** | flag (`superseded_at` / `superseded_reason`), never delete | the coalesce in `silv_member_base` is *per date* with the real row winning, so the row is already inert wherever real data covers it — and still filling a real gap wherever it does not |
| **Re-opening** | `superseded_at` cleared if the contact stops qualifying | same as `silv_data_anomaly` re-opening a resolved row |
| **Deletion** | never automatic | still a curated table; remove a row by hand |

`silv_member_base` deliberately does **not** test `superseded_at`. A contact who
gains a qualifying *election* row but still has no part-1 enrolment row keeps
their derived enrolment date; testing the flag would reopen that gap.

`Scripts/Maintenance/enrolment-exception-topup.sql` still exists but is
superseded. It reads the source views directly, so it can capture ahead of a
bronze load — at the cost of carrying the last hand-copied duplicate of the
qualifying rules. Prefer the module wherever bronze is current.

## Two paid member counts

The same module carries **two independent readings of "how many members have
paid"**, side by side, all the way through to the star. They answer the same
question from different source data and are **not expected to agree** — carrying
both is the point. Full rules in the header of `usp_load_silv_daily_count`.

| | silver | gold | driven by |
|---|---|---|---|
| Payment-driven | `paid_count` | `PaidMembers` | `silv_payment_events` — a paid subs invoice position for the campaign year, dated on or before the day |
| Event-driven | `paid_count_event` | `PaidMembersEvent` | `silv_membership_events` — joins + renewals + readmissions |

The event-driven measure works per contact per campaign year: paid from the
earliest **Join / Renewal / Readmission** event in that year, and counted for the
rest of it. Keyed on campaign year, so the number resets on each 1 October and
builds through the year — on any day, how many members have paid so far this
campaign year.

**Lapsing does not deduct.** A member who paid and then lapsed still paid, and
this measure counts that, which makes it monotonic within a campaign year. It is
the one place it parts company with every other count here — the active count,
and `paid_count` through its state-range gate, both stop at a lapse.

The substantive difference from `paid_count` is Join: it is the Join *event*
(enrolment-dated for Candidates, election-dated for RPQ direct entries), not a
payment — which is where the two measures diverge in a member's first year.

Component columns travel with it — `event_join_count`, `event_renewal_count`,
`event_readmission_count` in silver, `JoinEvents` / `RenewalEvents` /
`ReadmissionEvents` in gold. They are the daily *flows* behind the stock, so a
running total of `join + renewal + readmission` from the campaign year start
reproduces it. That reconciliation holds on the total rather than cell by cell:
the stock sits in the contact's cell on the day counted, the flow in their cell
on the event day.

`event_lapse_count` / `LapseEvents` sits alongside them, **reported but not
netted off** — the contacts who had paid in this campaign year and then lapsed
that day. It is not every lapse: a member bulk-lapsed on 1 June for never paying
has no paid-in behind them and does not appear. `fact_membership_events` has
every Lapse event if the unfiltered number is wanted.

Checks `C6d` and `C6e` in the pipeline reconciliation report cover the stock and
the flow-to-stock identity respectively.

Both measures are gated by the same state-range join as the active count, so
every driver exclusion on the active side removes the contact from both.

Both sets of columns are part of the phase 02 definitions, so a deployed
database has them from the start. Adding a further measure to a live database is
a migration under `07_Migrations/` — see **Changing a table's shape**.

## Reconciliation

Four ad hoc scripts in `Scripts/Reconciliation/`, run by hand rather than
deployed — see that folder's README for details and follow-up queries.
(`Scripts/Reset/` holds the two teardown scripts, covered above.)

**Start with the two difference lists.** They answer the question the client
actually asks — *why don't the numbers match?* — and they answer it completely:
every row carries a signed `count_impact`, and the sum over the whole list is
the difference between the official count and ours, exactly. Each asserts that
identity itself and prints PASS or FAIL.

- `active-member-difference.sql` — every contact in the official active list
  and not in ours, and vice versa, with the reason(s). Read-only.
- `paid-member-difference.sql` — the same for **both** paid measures:
  payment-driven (`paid_count` / `PaidMembers`) and event-driven
  (`paid_count_event` / `PaidMembersEvent`), each reconciled against the official
  query with its own identity, then compared against each other. Read-only.

The other two are older and broader:

- `pipeline-reconciliation-report.sql` — reconciles **layer totals** across
  source → bronze → silver → gold as a PASS/FAIL/WARN/INFO grid. Read-only.
- `contact-reconciliation.sql` — reconciles **list membership** contact by
  contact, recording the first logic gate each contact failed and why. Writes
  the three `recon_*` diagnostic tables (defined in `02_Tables/Reconciliation/`).

## Monitoring

```sql
-- latest run, step by step
select top 50 * from Layercake.etl_run_log
where run_id = (select top 1 run_id from Layercake.etl_run_log
                where layer = 'run' order by started_at desc)
order by log_id;

-- live sub-step progress during a long run (from another session)
exec Layercake.usp_etl_watch;

-- history that has drifted from source and is NOT rebuilt by the daily run
select * from Layercake.etl_daily_count_pending_rebuild where applied_at is null;
-- apply it deliberately (this can be a long walk):
exec Layercake.usp_load_silver @RebuildFrom = '2025-10-01';
```
