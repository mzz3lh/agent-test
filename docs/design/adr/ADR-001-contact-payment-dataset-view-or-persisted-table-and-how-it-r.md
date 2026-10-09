# ADR-001: Contact payment dataset: view or persisted table, and how it refreshes

| | |
|---|---|
| Status | proposed |
| Date | 2026-10-09 |
| Requirement IDs | REQ-001, REQ-005, REQ-006, REQ-007, REQ-008 |
| Decided by | pending: a human decides at the architecture validation gate |

## Context
REQ-007 asks for a queryable dataset in the Layercake schema that refreshes with the existing Layercake load schedule (RULE-020, RULE-021). AC-007-04 allows either a view or a table loaded by a procedure. The dataset covers every FO payment transaction (TRANSTYPE 15) in all legal entities and all history (RULE-001, RULE-002). Its sources are synapse_fo.CUSTTRANS and synapse_fo.CUSTPAYMMODETABLE (external, read-only, no indexes may be added), CE.tblContact_Test_Records (external) and the Layercake tables brnz_contact and dim_country. Each payment shows the contact's current country, so a change of country restates every past payment of that contact (RULE-016, AC-006-05). Totals must reconcile to FO for each legal entity (RULE-022). FO rows can be added, corrected or removed at the source. The spec gives no data volumes (see open question Q-025). In every option, the business rules are defined once, in the view Layercake.vw_fact_contact_payment_source, so they can be tested apart from how the result is stored.

## Options
### Option A: A. View only
The dataset is a view over FO, the CE test records, brnz_contact and dim_country. The rules are evaluated each time the reporting tool queries it. There is no load procedure and no stored copy.

Trade-offs: Always current, with no storage and no load step. Every report query scans the external FO transaction table across all history, and no index can be added to it, so report performance depends on FO volumes and on the external link. FO data is live while contact data is as at the last Layercake load. There is no load log entry (AC-007-04 does not apply), and the dataset cannot be indexed for reporting. The spec's proposed name fact_contact_payment would become a view name (vw_contact_payment) under the solution's conventions.

### Option B: B. Persisted table, rebuilt in full on each run
Layercake.fact_contact_payment is a table. On each scheduled run, Layercake.usp_load_fact_contact_payment replaces its whole content with the current output of the rules view, in one transaction, and logs the run through usp_etl_log_start and usp_etl_log_end.

Trade-offs: Simple, and idempotent by construction. Late, corrected and removed FO rows and contact country changes are all picked up on every run, so there is no change-detection logic to get wrong. Readers see either the previous or the new content, never a partial load. Report queries read a local table that can be indexed. Each run reads all TRANSTYPE 15 history and rewrites every row, so log volume and run time grow with FO history. created_at and updated_at only show the last rebuild.

### Option C: C. Persisted table, synchronised by key on each run
Same table and procedure as B. Each run compares the rules view's output with the table on legal_entity and fo_transaction_recid: it inserts new payments, updates rows where any reported column has changed (including country after a contact change), deletes rows no longer in the source, and leaves unchanged rows untouched.

Trade-offs: Writes only what changed, so the transaction log and the run time of the write phase stay small once history is loaded. created_at and updated_at stay meaningful, and the load log shows how many rows were inserted, updated and deleted. The whole source must still be read on every run, because a contact's country change restates old payments and FO rows can change without a reliable change marker. There is more logic to build and test (change detection on every column, delete handling).

## Recommendation
Option B: B. Persisted table, rebuilt in full on each run. A persisted table keeps report queries off the external FO tables and gives the load log that AC-007-04 expects. A full rebuild is the simplest way to meet the requirement that every run restates country for all history (AC-006-05), picks up corrected and removed FO rows, and gives the same result on a rerun (AC-007-03). Option C needs the same full read of the source on each run, so it only saves write effort, which matters only if volumes are large. This recommendation is provisional until Q-025 (volumes and load window) is answered. If volumes turn out to be large, moving to C changes only the load procedure, not the table, the rules view or the reconciliation view.

## Decision
Pending: filled in by a human at the architecture validation gate.

## Consequences
The design adds three objects: the rules view Layercake.vw_fact_contact_payment_source (MOD-001), the table Layercake.fact_contact_payment and its load procedure Layercake.usp_load_fact_contact_payment (MOD-002). The procedure is added to the existing Layercake load schedule after the brnz_contact and dim_country steps (open question Q-024). If A is chosen, MOD-002 is dropped: the rules view becomes the delivered dataset and is renamed, AC-006-05, AC-007-01 to AC-007-03, AC-008-01 and AC-008-02 move to MOD-001, and AC-007-04 does not apply. If C is chosen, only MOD-002's load behaviour and tests change.
