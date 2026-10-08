# Reconciliation scripts

Five ad hoc analysis scripts. **None are deployed** — `Deploy-Database.ps1`
only walks the numbered phase folders, so everything under `Scripts/` is skipped
automatically. Run these by hand, when you want to answer a question.

| Script | Scope | Writes? |
|---|---|---|
| `active-member-difference.sql` | Accounts for **every unit** of the active count difference, contact by contact | No. Read-only, `#temp` tables only |
| `paid-member-difference.sql` | The same for **both** paid counts — payment-driven and event-driven — plus the two measures compared | No. Read-only, `#temp` tables only |
| `pipeline-reconciliation-report.sql` | Reconciles **layer totals** — source → bronze → silver → gold | No. Read-only, `#temp` tables only |
| `contact-reconciliation.sql` | Reconciles **list membership**, contact by contact | Yes — the three `recon_*` diagnostic tables |
| `silver-events-ranges-counts.sql` | Quick **silver-internal** check: events → state ranges → daily counts, each step re-derived and compared to what is stored | No. Read-only, `#temp` tables only |

All five need the database project deployed and the daily load to have run at
least once.

---

## The difference lists

`active-member-difference.sql` and `paid-member-difference.sql` are the two to
reach for first. Each answers one question — *why doesn't the official number
match ours?* — and answers it **completely**.

```
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i active-member-difference.sql -b -N -I
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i paid-member-difference.sql   -b -N -I
```

Two knobs at the top of each: `@asof` (defaults to today, and that is the only
fully meaningful setting — the source views are current-state) and
`@layercake_source`, `GOLD` (default, what Power BI shows) or `SILVER`.

### The guarantee

Every row of the list carries a signed `count_impact`:

| | meaning |
|---|---|
| `+1` | the contact is in the official list and **not** in the Layercake number |
| `-1` | the contact is in the Layercake number and **not** in the official list |

plus a few **bridge** rows (`B01`–`B05`) for the differences that are not
contact-level membership at all — a source row with no contact number, a
contact holding two source rows, a contact counted twice by an overlapping
state range, stored-vs-derived drift, gold behind silver.

```
sum(count_impact) over the whole list  ==  official count - Layercake count
```

**RS-1 asserts exactly that and prints PASS or FAIL.** If it is not PASS, do
not quote the list: something in the rule set has stopped being true. Same for
a non-zero `A99` / `X99` / `P99` / `Q99` — those are the "unexplained"
residuals, and they are there so a gap shows up as a number rather than as a
silently wrong list.

### Result sets

| | |
|---|---|
| RS-0 | Run context — as-of date, campaign year, anchor, whether as-of is today |
| RS-1 | The assertion: official, Layercake, difference, sum of impacts, PASS/FAIL |
| RS-2 | The bridge, line by line — official rows → official contacts → Layercake contacts → cells → stored → gold |
| RS-3 | Reason summary — one row per reason code, with its net impact |
| RS-4 | **The list** — one row per unit of difference, with `reason_code`, `all_reasons` and the full diagnostic set |

`reason_code` is the **first** rule the contact fell foul of, walked in
pipeline order. `all_reasons` is every code that applies, which is what to read
when one contact breaks several rules at once. The reason codes themselves are
documented in the header of each script.

### Why a bridge is needed at all

The two ends are different kinds of number. The official side counts **rows**
in a current-state source view. The Layercake side is a sum over
`(region, grade)` **cells**, each counting distinct contacts, on a stored daily
aggregate that is loaded forward-only. `B01`–`B03` are the conversions between
those two shapes; `B04`–`B05` are staleness between the layers. Without them
the two numbers cannot be made to agree by construction, and any "list of
differences" is an approximation.

### Both paid measures

`paid-member-difference.sql` covers **both** readings of "how many members have
paid", each reconciled against the same official query with its own identity,
and then compared against each other. Every row carries a `measure`:

| `measure` | reads | silver / gold |
|---|---|---|
| `PAYMENT` | the subs invoice position — the same data the official query reads | `paid_count` / `PaidMembers` |
| `EVENT` | membership events: Join + Renewal + Readmission | `paid_count_event` / `PaidMembersEvent` |

RS-1 returns one row per measure with its own PASS/FAIL, and `sum(count_impact)`
**within each measure** equals that measure's difference. RS-2 walks both
bridges. The reason codes split accordingly: `P01`–`P06` are the payment
paid-in chain, `E01`–`E04` the event paid-in chain, and `P10`–`P22` — the
state-range gate — are **shared**, because both measures join the same state
ranges as the active count.

**The two are not expected to agree, and that is the point.** Two rules drive
nearly every divergence:

- **Join is an event, not a payment.** It is enrolment-dated for Candidates and
  election-dated for RPQ direct entries, so `EVENT` counts a member who joined
  this campaign year before any money moves.
- **Lapsing does not deduct**, so `EVENT` is monotonic within a campaign year
  while `PAYMENT` stops at a lapse through the state-range gate.

`EVENT` also resets to zero every 1 October and builds through the year, so
early in a campaign year it is *supposed* to sit far below the official number —
that is the measure working, not a fault, and it shows up as `E04`.

**RS-5 / RS-5b / RS-6** are the measure-vs-measure comparison: `M01`–`M05` for
contacts only `EVENT` counts, `M10`–`M12` for contacts only `PAYMENT` counts,
with its own PASS/FAIL that the two lists net to the gap between the measures.
Start at RS-5 when the question is "why are our two paid numbers different?"
rather than "why don't we match the client?"

See *Two paid member counts* in `database/README.md` for the rules themselves.

---

The two scripts below predate the difference lists and are broader: one
reconciles layer totals rather than membership, the other walks the same gates
but does not close the arithmetic. Both are still useful — the pipeline report
for "is the pipeline healthy", the contact reconciliation for its persisted
`recon_*` tables and its anomaly register.

## Pipeline reconciliation report

Every check as one row of a PASS / FAIL / WARN / INFO summary grid, then detail
sets for the interesting failures, then individual-contact spot checks traced
layer by layer.

```
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i pipeline-reconciliation-report.sql -b -N -I
```

Knobs at the top of the file: `@check_source` (set to 0 for a fast
Layercake-only run that skips the live source views), `@spot_sample`,
`@detail_rows`.

Read-only and safe to run any time. Source-vs-bronze checks compare **live**
source views against the snapshot the last bronze load took, so running mid-day
shows timing drift rather than corruption — those checks are deliberately WARN,
not FAIL. Re-run straight after the daily load to confirm.

## Contact reconciliation

Takes the two agreed "correct" lists — active members from `CE.vwContact`, paid
members from `Subs.vwSubsMemberStatuses` — and reconciles them contact by
contact against what the pipeline produced. Every contact in either list gets a
row carrying its state at each gate of the bronze → silver logic, plus the
**first gate it failed** and why.

```
sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i contact-reconciliation.sql -b -N -I
```

Knobs at the top: `@asof` (defaults to today), `@keep_history` (0 replaces the
previous run, 1 accumulates), `@examples`.

Results land in `Layercake.recon_run` (one row per reconciliation, with the
headline counts) and `Layercake.recon_active_contact` /
`Layercake.recon_paid_contact` (one row per contact). Typical follow-up:

```sql
-- where are contacts being lost?
select fail_gate, fail_reason, count(*) as contacts
from Layercake.recon_active_contact
where run_id = (select top 1 run_id from Layercake.recon_run order by run_at desc)
  and recon_status = 'SOURCE_ONLY'
group by fail_gate, fail_reason
order by contacts desc;
```

### Anomaly scenarios

Contacts the pipeline counts but the truth query drops are not a gate failure —
nothing was lost — so they carry an **X-series** code naming the *mechanism*
instead. Read them in RS-4a, or straight from the table:

| Code | Mechanism |
|---|---|
| `X10` | No `CE.vwContact` row at all |
| `X20` / `X21` / `X22` | Lapse code **Deceased** (200000000) / **Duplicate** (200000001) / other, with **no lapse date anywhere** |
| `X30` | Lapse date on `brnz_rics_record` but not on the contact — silver only ever reads the contact date |
| `X40` | Contact lapse date invalidated by the stale-lapse rule |
| `X50` | No rics record at all — **retired by gate `A26`**, so this should now be zero; a row here means the rule is not deployed |
| `X55` | No transaction history at all — **retired by gate `A27`**, same shape as `X50` and expected to be zero for the same reason |
| `X60` | Rics grade is not a member grade (on a record that *exists* — the driver excludes only Student and no-record-at-all) |
| `X70` | Active purely from a payment-derived Readmission |
| `X99` | Excluded on grade / lapse code / state code, no mechanism above |

Gate `A90` (lapsed in the pipeline, active in source) splits three ways, so a
lapse that contradicts other evidence on the same contact is named rather than
lumped in: `LAPSED_DESPITE_LATER_ENROLMENT` (a qualifying enrolment postdates
the lapse — `silv_member_base` tests the lapse against the *earliest*
enrolment, so a re-enrolled member keeps their Lapse),
`LAPSED_DESPITE_PAYMENT_THIS_CY` (counted paid and not counted active on the
same date), and the residual `LAPSED_IN_PIPELINE_NOT_IN_SOURCE`.

### Contacts with no rics record

A contact with no row in `brnz_rics_record` has no grade, lapse code or
retirement date behind it, so it is not a member by the source definition. Gate
`A26` excludes it from the `silv_member_base` driver, and the payment-derived
Readmission in module 9 repeats the same test — that is the only event that can
open a state range without a member-base row, so without it a payment alone
would put the contact straight back into the active count.

The excluded cohort is not silently dropped: `usp_load_silv_data_anomaly` logs
it as `NO_RICS_RECORD`, one row per contact number, and that is the list to feed
back to the client.

```sql
select contact_no, detail, first_detected_at, last_seen_at
from Layercake.silv_data_anomaly
where anomaly_type = 'NO_RICS_RECORD' and resolved_at is null
order by contact_no;
```

Like every anomaly type it self-retires: once source lands a rics record the
contact returns to the base on the next run and the row is stamped
`resolved_at` rather than deleted.

### Contacts with no transaction history

The same shape, one gate later. A contact with no row in `brnz_cust_trans` has
never transacted, so it is not a valid contact: gate `A27` excludes it from the
`silv_member_base` driver and module 9 repeats the test on the payment-derived
Readmission. It counts as neither **active** nor **paid** — the paid number
joins the same state ranges as the active number, so removing the range removes
both. The test is *existence* of a transaction, not a settled or approved one;
the `approved = 1` rule stays where it belongs, in the payment derivation.

`NO_TRANSACTIONS` logs only the contacts whose removal **contradicts** something
— a valid enrolment or election (or curated `07` fallback dates) exists behind
them. A contact with no transactions and no qualifying enrolment is not a member
on any reading, and listing it would bury the real cases.

```sql
select contact_no, detail, first_detected_at, last_seen_at
from Layercake.silv_data_anomaly
where anomaly_type = 'NO_TRANSACTIONS' and resolved_at is null
order by contact_no;
```

The full size of the exclusion — including the contacts *not* logged, because
they had no enrolment either — is RS-11 divergence 22, with the paid-side
number as divergence 23. That paid one is worth reading twice: those contacts
hold a **paid invoice position** for the campaign year yet have no cash
transaction anywhere. They are reported as `P60` / `NO_TRANSACTION_HISTORY`.

**RS-14** is the register: every scenario sized, each marked `NO RULE YET`
(no date exists to act on — Deceased / Duplicate), `RULE NEEDED` (the evidence
is there, silver just does not read it) or `RULE EXISTS`, with the query that
lists its contacts. That is the list to work through, and the counts to watch
after each rule change.

Because the scenario columns are new, a database whose `recon_*` tables were
deployed before them still carries the old shape, and the inserts fail with one
`Invalid column name` per missing column. The script preflights for it and names
every missing column in a single message. They are diagnostic tables, rebuilt
from scratch on every run, so the fix is to drop and redeploy them:

```sql
drop table Layercake.recon_active_contact;
drop table Layercake.recon_paid_contact;
drop table Layercake.recon_run;
```

```powershell
.\Deploy-Database.ps1 -Phase 02 -Filter Reconciliation
```

Run the script with `-b`, as above: the preflight is severity 16, which stops
the run under `sqlcmd -b` but *not* in SSMS — there the column errors follow the
message anyway, as consequences of it.

## Table ownership

The three `recon_*` tables are defined in `02_Tables/Reconciliation/` like every
other table in the project. Earlier revisions of `contact-reconciliation.sql`
created them inline and dropped/rebuilt them via column version markers when the
diagnostics changed; that block has been removed, so there is one definition in
one place.

**Change their shape in `02_Tables/Reconciliation/`, not here.** The script
preflights for the tables and tells you to deploy the project if they are
missing.
