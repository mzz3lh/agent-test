# Operational runbook: RICS Phase 2

## Components and load order

| Component | Type | Module | What it does in operation |
|---|---|---|---|
| Layercake.vw_fact_contact_payment_source | View | MOD-001 | Applies the dataset's business rules to the FO, CRM test-record and Layercake contact and country data each time it is read. It has no load of its own and keeps no data. It is read by the dataset's load procedure, not by report users. |
| Layercake.fact_contact_payment | Table | MOD-002 | The reporting table that report users read. Its whole content is replaced on every load run. |
| Layercake.usp_load_fact_contact_payment | Load procedure | MOD-002 | Rebuilds the reporting table in full from the rules view, in one transaction, and logs the run. |
| Layercake.usp_load_gold | Existing load step (changed) | MOD-002 | Calls the payment load as its last step. |
| Layercake.vw_contact_payment_reconciliation | View | MOD-003 | Compares the reporting table with FO for each legal entity each time it is read. It has no load of its own and keeps no data. |

Load order: the payment load runs as the last step of the existing Layercake gold load, after all of its dimension loads and its three existing fact loads. It reads the Layercake contact data (brnz_contact) and the country dimension (dim_country) through the rules view, so it runs after they have been loaded in the same Layercake run. The reconciliation view is not part of the load: it reads the reporting table as the latest payment load left it, and FO directly, whenever it is queried.
<!-- evidence: docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/DES-001.json#is the only input to the load procedure; docs/design/DES-001.json#Layercake.fact_contact_payment; docs/design/DES-001.json#Layercake.usp_load_fact_contact_payment; docs/design/DES-001.json#Scheduling (Q-024); docs/design/DES-001.json#Layercake.vw_contact_payment_reconciliation; docs/dev/CN-MOD-002.json#after the three existing facts and so after every dimension step; docs/test/TCS-MOD-002.json#TC-002-016; docs/design/MP-001.json#MOD-003; docs/dev/CN-MOD-003.json#Dataset side: read from Layercake.fact_contact_payment -->

## Scheduling

The dataset refreshes as part of the existing Layercake load schedule; it has no schedule of its own. The scheduled entry point of that load is Layercake.usp_run_daily_load, which runs the bronze, silver and gold loads under one run ID. The gold load (Layercake.usp_load_gold) calls the payment load at its end and passes the same run ID, so the payment load's log entry can be matched to the rest of the Layercake run.

When and how often the Layercake schedule runs in production is still to be confirmed.
<!-- evidence: docs/specs/SPEC-001.json#RULE-021; docs/specs/SPEC-001.json#With the existing Layercake load schedule; docs/design/DES-001.json#Scheduling (Q-024); docs/design/DES-001.json#Layercake.usp_run_daily_load is the scheduled entry point; docs/dev/CN-MOD-002.json#passing @run_id; docs/test/TCS-MOD-002.json#TC-002-016 -->

## Monitoring

Each payment load run writes one entry in the existing Layercake run log, Layercake.etl_run_log, under the run ID of the Layercake run (or its own run ID when run on its own):

| Item | What is recorded |
|---|---|
| Layer and step | Layer 'gold', step 'fact_contact_payment'. |
| Start and finish | The start time is recorded before the load begins, so it is kept even if the run fails; the finish time is recorded when the run ends. |
| Outcome | 'Success' or 'Failed'. |
| Row counts on success | Rows inserted (the number of payments now in the dataset), rows updated (always 0 for a full rebuild) and rows deleted (the number of rows the dataset held before the run). |
| On failure | Row counts of 0 and the error message, with the error number and line. |

Errors are also recorded in the error log, audit.ErrorLog (see Error handling).
<!-- evidence: docs/design/DES-001.json#Load logging; docs/specs/SPEC-001.json#AC-007-04; docs/dev/CN-MOD-002.json#layer 'gold', step 'fact_contact_payment'; docs/dev/CN-MOD-002.json#The log start entry is written before the transaction; docs/dev/CN-MOD-002.json#inserted = rows inserted, updated = 0 and deleted = previous rows; docs/dev/CN-MOD-002.json#counts 0/0/0; docs/test/TCS-MOD-002.json#TC-002-009; docs/test/TCS-MOD-002.json#TC-002-010 -->

### Checking the dataset against FO

The business and support staff can check the dataset against FO at any time, including in production, by reading the reconciliation view, Layercake.vw_contact_payment_reconciliation, from the reporting tool once read access has been granted (see Access for report users). It lists each legal entity with the dataset's row count and GBP total next to the FO figures. is_reconciled shows 1 where both counts and both totals agree and 0 where they do not. A legal entity with payments on one side only still appears, with 0 for the other side. See the Data model in the Architecture document for each column.

This check is also how the GBP working assumption (Q-014) is to be confirmed on real data (see Known limitations).

The view reads the full FO payment history every time it is queried, so it is meant for occasional checks rather than for use in every report.
<!-- evidence: docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#including on production after go-live; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#run occasionally; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Q-014; docs/design/DES-001.json#Layercake.vw_contact_payment_reconciliation; docs/dev/CN-MOD-003.json#is_reconciled is 1 only when both counts and both totals are equal; docs/dev/CN-MOD-003.json#meant for occasional checks; docs/test/TCS-MOD-003.json#TC-003-005; docs/test/TCS-MOD-003.json#TC-003-006 -->

## Error handling

The payment load runs in one transaction. If anything fails during the run:

- Everything the run did is undone, so the reporting table keeps exactly the content it had before the run. Reports keep showing the dataset as at the last successful run.
- The error is written to the error log, audit.ErrorLog, with its error number and message. These entries are not linked to a load-log ID (see Known limitations); the run itself is recorded in Layercake.etl_run_log as 'Failed'.
- The error is passed back to whatever started the load, so the failure is not hidden.

For example, testing showed that if the source ever held the same payment (legal entity and FO record ID) twice, the load fails on the table's primary key, the error is logged, and the previous dataset stays in place.
<!-- evidence: docs/design/DES-001.json#Layercake.usp_load_fact_contact_payment; docs/design/DES-001.json#Load logging; docs/dev/CN-MOD-002.json#On failure the procedure rolls back; docs/dev/CN-MOD-002.json#LoadId is NULL there; docs/test/TCS-MOD-002.json#TC-002-010; BASE_STANDARDS.md#No silent swallowing -->

## Recovery and reruns

A failed run changes nothing in the dataset, so it can simply be run again once the cause of the error has been fixed. Because every run rebuilds the whole dataset from the current sources, a rerun never duplicates rows and, with unchanged sources, gives the same row counts and totals for every legal entity. The next scheduled Layercake run also rebuilds the dataset in full, so it brings the dataset up to date without any other step.

The payment load can also be run on its own, outside the Layercake run; it then records itself in the run log under a newly created run ID. Permission to run it is given only to the identity that runs the Layercake schedule.
<!-- evidence: docs/design/DES-001.json#Rerunning with; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#idempotent by construction; docs/dev/CN-MOD-002.json#The previous content stays in place; docs/dev/CN-MOD-002.json#generates a run id when called standalone; docs/dev/CN-MOD-002.json#EXECUTE on the load only for the identity that runs the Layercake schedule; docs/test/TCS-MOD-002.json#TC-002-007; docs/test/TCS-MOD-002.json#TC-002-008 -->

## Deployment and rollback

### How migrations behave

Each module is deployed by a migration: an up script that applies it and a down script that reverses it. Under the project's deployment standard:

- Each script checks first whether the migration is already applied, so running it a second time changes nothing.
- Each script runs in one transaction and stops on the first error, so a failed deployment leaves nothing half-applied and can be run again once the cause is fixed.
- Every up and down run is recorded in the migration history (etl.MigrationHistory); etl.vw_MigrationState shows whether each migration is currently applied and etl.vw_DatabaseVersion shows the database's version.
- A down script runs only in reverse order: it refuses while a later migration is applied. Migrations are therefore rolled back newest first (MIG-0005, then MIG-0004, then MIG-0003).
- A down script does not silently destroy data: a table that holds rows is renamed rather than dropped.
<!-- evidence: BASE_STANDARDS.md#Idempotent; BASE_STANDARDS.md#Transactional; BASE_STANDARDS.md#etl.MigrationHistory; BASE_STANDARDS.md#Rollback for every deployment; BASE_STANDARDS.md#never silently destroys data; docs/dev/CN-MOD-001.json#MIG-0003; docs/dev/CN-MOD-002.json#MIG-0004; docs/dev/CN-MOD-003.json#MIG-0005 -->

### MOD-001: migration MIG-0003

The rules view is deployed by migration MIG-0003 (contact payment rules view): the up script creates the view and the down script removes it.

| Script | Path |
|---|---|
| Up | src/sql/deploy/MIG-0003_MOD-001_contact-payment-rules-view.up.sql |
| Down | src/sql/deploy/MIG-0003_MOD-001_contact-payment-rules-view.down.sql |

The rollback was tested on the development database (RICS_Dev) on 2026-10-09 and passed every step: the up script applied and recorded itself; a second up changed nothing; the down script restored the schema to its state before the migration and recorded itself; a second down changed nothing; and re-applying after the rollback gave the same result as the first apply.
<!-- evidence: docs/dev/CN-MOD-001.json#MIG-0003; docs/dev/CN-MOD-001.json#rollback_test; docs/dev/CN-MOD-001.json#RICS_Dev -->

### MOD-002: migration MIG-0004

The reporting table, its load procedure and the change to the existing gold load are deployed by migration MIG-0004 (contact payment table, full-rebuild load). The up script creates the table and the load procedure and adds the payment load call to Layercake.usp_load_gold. The down script returns the schema to its state before the migration, including restoring the previous definition of Layercake.usp_load_gold.

| Script | Path |
|---|---|
| Up | src/sql/deploy/MIG-0004_MOD-002_contact-payment-table-full-rebuild-load.up.sql |
| Down | src/sql/deploy/MIG-0004_MOD-002_contact-payment-table-full-rebuild-load.down.sql |

The rollback was tested on the development database (RICS_Dev) on 2026-10-15 and passed every step: the up script applied and recorded itself; a second up changed nothing; the down script restored the schema to its state before the migration and recorded itself; a second down changed nothing; and re-applying after the rollback gave the same result as the first apply.
<!-- evidence: docs/dev/CN-MOD-002.json#MIG-0004; docs/dev/CN-MOD-002.json#rollback_test; docs/dev/CN-MOD-002.json#RICS_Dev; docs/dev/CN-MOD-002.json#Its down script restores the previous definition; docs/design/MP-001.json#with a down script that restores it -->

### MOD-003: migration MIG-0005

The reconciliation view is deployed by migration MIG-0005 (per-legal-entity reconciliation view): the up script adds the view and the down script returns the schema to its state before the migration.

| Script | Path |
|---|---|
| Up | src/sql/deploy/MIG-0005_MOD-003_per-legal-entity-reconciliation-view.up.sql |
| Down | src/sql/deploy/MIG-0005_MOD-003_per-legal-entity-reconciliation-view.down.sql |

The rollback was tested on the development database (RICS_Dev) on 2026-10-15 and passed every step: the up script applied and recorded itself; a second up changed nothing; the down script restored the schema to its state before the migration and recorded itself; a second down changed nothing; and re-applying after the rollback gave the same result as the first apply.
<!-- evidence: docs/dev/CN-MOD-003.json#MIG-0005; docs/dev/CN-MOD-003.json#rollback_test; docs/dev/CN-MOD-003.json#RICS_Dev; docs/dev/CN-MOD-003.json#down restores the pre-migration schema -->

### Access for report users

Read access is not part of the migrations. A person reviews and runs the grants separately, for the role the reporting tool already uses to read Layercake: read access on the reporting table, Layercake.fact_contact_payment, and on the reconciliation view, Layercake.vw_contact_payment_reconciliation. The rules view is not granted to report users. Readers of the reconciliation view rely on its database ownership to read the FO and CRM test-record tables behind it. The role's name is still to be confirmed (see Known limitations).
<!-- evidence: docs/design/DES-001.json#a human reviews and runs them; docs/dev/CN-MOD-002.json#Read grant not scripted as a file; docs/dev/CN-MOD-002.json#No grant on the rules view; docs/dev/CN-MOD-003.json#the role the reporting tool already uses to read Layercake; docs/dev/CN-MOD-003.json#ownership chain; docs/design/DES-001.json#is not granted to report users -->

### Environments

The solution was built on a development database (RICS_Dev), which holds only synthetic or masked data, and tested on a separate test database (RICS_Test), which holds only synthetic data and is rebuilt clean for each test run. The test framework and test schemas exist only in development and test and are never deployed further. Production is the client's own environment, holding real data, and a person deploys the migrations there. The production server and database, and who carries out the production deployment, are still to be confirmed.
<!-- evidence: docs/setup/ENVIRONMENTS.md#RICS_Dev; docs/setup/ENVIRONMENTS.md#RICS_Test; docs/setup/ENVIRONMENTS.md#Rebuilt clean; docs/setup/ENVIRONMENTS.md#never deployed further; docs/setup/ENVIRONMENTS.md#Humans deploy; docs/dev/CN-MOD-001.json#MIG-0003; docs/dev/CN-MOD-002.json#MIG-0004; docs/dev/CN-MOD-003.json#MIG-0005 -->
