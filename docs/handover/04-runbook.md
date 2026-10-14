# Operational runbook: RICS Phase 2

## Components and load order

| Component | Type | Module | What it does in operation |
|---|---|---|---|
| Layercake.vw_fact_contact_payment_source | View | MOD-001 | Applies the dataset's business rules to the FO, CRM test-record and Layercake contact and country data each time it is read. It has no load of its own and keeps no data. It is read by the dataset's load procedure, not by report users. |

The reporting table and its load (MOD-002) and the reconciliation view (MOD-003) will be added to this runbook as they are delivered.
<!-- evidence: docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/DES-001.json#is the only input to the load procedure; docs/design/MP-001.json#MOD-001; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003 -->

## Scheduling

_Not yet documented._

## Monitoring

_Not yet documented._

## Error handling

_Not yet documented._

## Recovery and reruns

_Not yet documented._

## Deployment and rollback

### MOD-001: migration MIG-0003

The rules view is deployed by migration MIG-0003 (contact payment rules view), which has an up script that creates the view and a down script that removes it.

| Script | Path |
|---|---|
| Up | src/sql/deploy/MIG-0003_MOD-001_contact-payment-rules-view.up.sql |
| Down | src/sql/deploy/MIG-0003_MOD-001_contact-payment-rules-view.down.sql |

How migrations behave, under the project's deployment standard:

- Each script checks first whether the migration is already applied, so running it a second time changes nothing.
- Each script runs in one transaction and stops on the first error, so a failed deployment leaves nothing half-applied and can be run again once the cause is fixed.
- Every up and down run is recorded in the migration history (etl.MigrationHistory); etl.vw_MigrationState shows whether each migration is currently applied and etl.vw_DatabaseVersion shows the database's version.
- A down script runs only in reverse order: it refuses while a later migration is applied. To roll back MIG-0003 after later migrations have been deployed, roll those back first.

The rollback was tested on the development database (RICS_Dev) on 2026-10-09 and passed every step: the up script applied and recorded itself; a second up changed nothing; the down script restored the schema to its state before the migration and recorded itself; a second down changed nothing; and re-applying after the rollback gave the same result as the first apply.

Which environments MIG-0003 is deployed to, and who runs the deployment there, is still to be confirmed.
<!-- evidence: docs/dev/CN-MOD-001.json#MIG-0003; docs/dev/CN-MOD-001.json#rollback_test; docs/dev/CN-MOD-001.json#RICS_Dev; BASE_STANDARDS.md#Idempotent; BASE_STANDARDS.md#Transactional; BASE_STANDARDS.md#etl.MigrationHistory; BASE_STANDARDS.md#Rollback for every deployment -->
