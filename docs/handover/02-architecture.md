# Architecture and data model: RICS Phase 2

## Architecture overview

The dataset is added to the existing Layercake solution and follows its conventions: objects in the Layercake schema with lower-case names, and load runs logged through the existing Layercake run log. The solution is organised in these layers:

| Layer | Objects | Role |
|---|---|---|
| Sources (owned by other systems, read only) | synapse_fo.CUSTTRANS, synapse_fo.CUSTPAYMMODETABLE, CE.tblContact_Test_Records | FO customer transactions, FO payment modes and CRM test contacts. Read, never changed. |
| Existing Layercake objects (read without change) | Layercake.brnz_contact, Layercake.dim_country | CRM contacts with contact number, country and deleted flag; country, region and market reporting region. |
| New Layercake dataset | Layercake.vw_fact_contact_payment_source (built, MOD-001) | Applies every business rule of the dataset in one place, at one row per FO payment transaction. |
| New Layercake dataset | Layercake.fact_contact_payment and its load procedure Layercake.usp_load_fact_contact_payment (built, MOD-002) | The reporting table read by the reporting tool, rebuilt in full from the rules view on every run. |
| New Layercake dataset | Layercake.vw_contact_payment_reconciliation (built, MOD-003) | Compares the reporting table with FO for each legal entity, so the business can confirm the totals. |
| Existing Layercake load (changed) | Layercake.usp_load_gold (MOD-002) | The existing Layercake load step that now also calls the payment load (see the Runbook). |
| Load logging (existing, unchanged) | Layercake.etl_run_log through Layercake.usp_etl_log_start and Layercake.usp_etl_log_end; audit.ErrorLog through audit.usp_LogError | Records the start, end, row counts and outcome of each load run, and the details of any error. |

The business rules are defined once, in the rules view, so they can be tested apart from how the result is stored. The rules view is the only input to the load procedure, which only stores its output. The reconciliation view works out the FO side directly from the FO and CRM test-record sources, separately from the rules view, so it is an independent cross-check of the dataset.
<!-- evidence: docs/design/DES-001.json#layers; docs/design/DES-001.json#Load logging; docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/DES-001.json#Rules in one place; docs/design/DES-001.json#Layercake.vw_contact_payment_reconciliation; docs/design/MP-001.json#MOD-001; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003; docs/dev/CN-MOD-002.json#Layercake.usp_load_gold; PROJECT_STANDARDS.md#Load logging; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#defined once; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#independently of the dataset's rules view -->

## Data model

### Layercake.vw_fact_contact_payment_source (rules view)

One row per FO payment transaction, identified by its legal entity and FO record ID. It covers FO customer transactions of type 15 ('Payment') from all legal entities and all dates, including cancelled payments, and leaves out any payment whose account number is a CRM test contact number. It is the input to the reporting table and is not made available to report users.

No lookup can repeat a payment. Where an account number matches more than one current (not deleted) CRM contact, one contact is used: the one with the lowest contact ID, so every run gives the same result.

| Column | Meaning and rule |
|---|---|
| legal_entity | FO legal entity (company) holding the transaction, as recorded. With fo_transaction_recid, identifies the payment. |
| fo_transaction_recid | FO record ID of the transaction, as recorded. |
| account_number | FO account the payment was posted to, as recorded. |
| contact_number | The matched current CRM contact number for contact payments; empty for corporate payments. |
| is_corporate | 0 when the account number matches the contact number of at least one current CRM contact, in any legal entity; otherwise 1 (corporate). |
| payment_date | The adjusted FO date: the document date when it is on or before 2021-08-23 and not in 1900; otherwise the transaction date, including when there is no document date. Same rule as the existing FO reporting (see Known limitations for the 23 August 2021 boundary). |
| payment_year | Calendar year of payment_date. |
| payment_month | Calendar month (1 to 12) of payment_date, not the fiscal period. |
| amount_paid_currency | Amount in the currency paid, sign reversed so money received is positive and refunds or reversals are negative. Kept at FO's six decimal places, with no rounding (assumed, Q-023). |
| currency_code | Currency paid, as recorded. |
| amount_paid_gbp | Accounting-currency amount, sign reversed in the same way, six decimal places, no rounding. Labelled GBP (assumed, Q-014). |
| payment_method_code | FO payment mode code as recorded; 'Unknown' when the code is missing, empty or only spaces. |
| payment_method | Name of the payment mode in the transaction's own legal entity. 'Unknown' when there is no code. The code itself when the legal entity has no row for that code, or its name is missing or blank. |
| country_name | Country of the matched contact's current CRM country. 'Unknown' for corporate payments, for contacts with no country, and where the country has no row in the country dimension. |
| region_name | Region from the same country lookup; 'Unknown' wherever country_name is 'Unknown' (assumed, Q-022). |
| market_reporting_region | Market reporting region from the same lookup; 'Unknown' wherever country_name is 'Unknown' (assumed, Q-022). |

Values that are missing in FO (account number, amounts, currency, dates) are carried through as empty values; the row is kept, not dropped.
<!-- evidence: docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/DES-001.json#lowest ContactId; docs/design/DES-001.json#Q-022; docs/design/DES-001.json#Q-023; docs/design/DES-001.json#Q-014; docs/specs/SPEC-001.json#RULE-004; docs/specs/SPEC-001.json#RULE-009; docs/specs/SPEC-001.json#RULE-010; docs/test/TCS-MOD-001.json#TC-001-006; docs/test/TCS-MOD-001.json#TC-001-015; docs/dev/CN-MOD-001.json#space-only -->

### Layercake.fact_contact_payment (reporting table)

The delivered dataset for the reporting tool: one row per FO payment transaction. Its primary key is the legal entity and FO record ID, so no payment can appear twice. It has no links (foreign keys) to other tables: country, region and market are held as names.

It holds every column of the rules view, with the same meaning and rules (see the rules view above), plus three run and audit columns:

| Column | Meaning |
|---|---|
| legal_entity to market_reporting_region | The sixteen columns of the rules view, in the same order, as the rules view gives them. |
| run_id | The ID of the load run that wrote the row, as recorded in the Layercake run log (Layercake.etl_run_log). |
| created_at | UTC time the row was written. Every row written by one run has the same value. |
| updated_at | UTC time the row was last written. Because the table is rebuilt in full on each run, it always equals created_at (see Known limitations). |

All object and column names are lower case with underscores, following the Layercake conventions.
<!-- evidence: docs/design/DES-001.json#Layercake.fact_contact_payment; docs/design/DES-001.json#No foreign keys; docs/design/DES-001.json#Equals created_at under a full rebuild; docs/design/DES-001.json#as recorded in Layercake.etl_run_log; docs/dev/CN-MOD-002.json#PK_Layercake_fact_contact_payment; docs/dev/CN-MOD-002.json#one shared stamp with created_at equal to updated_at; docs/test/TCS-MOD-002.json#TC-002-002; docs/specs/SPEC-001.json#RULE-020 -->

### Layercake.usp_load_fact_contact_payment (load procedure)

Rebuilds Layercake.fact_contact_payment in full from the rules view, in one transaction: it removes the table's previous content and inserts the rules view's current output, stamping every row with the run's ID and one shared time. Readers therefore see either the previous or the new dataset, never a partly loaded one. Because each run rebuilds everything, payments added, corrected or removed in FO since the last run, and contact country changes, are all reflected after the next run, and a rerun with unchanged sources gives the same result.

It is called with the run ID of the Layercake run it belongs to; when it is run on its own without one, it creates a new run ID, like every other Layercake load. Each run is logged in the Layercake run log, and errors also in the error log (see the Runbook for monitoring and error handling).
<!-- evidence: docs/design/DES-001.json#Layercake.usp_load_fact_contact_payment; docs/design/DES-001.json#readers see either the previous or the new dataset; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#Option B; docs/dev/CN-MOD-002.json#full rebuild in one transaction; docs/dev/CN-MOD-002.json#generates a run id when called standalone; docs/test/TCS-MOD-002.json#TC-002-004; docs/test/TCS-MOD-002.json#TC-002-005; docs/test/TCS-MOD-002.json#TC-002-007; docs/test/TCS-MOD-002.json#TC-002-011 -->

### Layercake.usp_load_gold (existing load step, changed)

The existing Layercake gold load step now ends with one call to the payment load, passing on its own run ID. Nothing else in it was changed.
<!-- evidence: docs/design/MP-001.json#MOD-002; docs/dev/CN-MOD-002.json#one call added at the end; docs/test/TCS-MOD-002.json#TC-002-016 -->

### Layercake.vw_contact_payment_reconciliation (reconciliation view)

One row per legal entity found on either side, so a legal entity that is missing from one side still shows, with that side's figures as 0. A legal entity that has neither payments in the dataset nor in-scope FO payments does not appear.

- **Dataset side:** the row count and amount_paid_gbp total of the reporting table, Layercake.fact_contact_payment.
- **FO side:** worked out directly from the FO customer transactions, independently of the rules view: transactions of type 15, cancelled payments kept, payments on test accounts left out. Transactions with no account number are counted. The total is the accounting-currency amount with its sign reversed, taken to be GBP (assumed, Q-014).

| Column | Meaning |
|---|---|
| legal_entity | The FO legal entity. Legal entities whose codes differ only in upper or lower case are treated as one, as in the reporting table's primary key. |
| dataset_row_count | Number of payments in the reporting table for the legal entity; 0 when it has none. |
| fo_row_count | Number of in-scope FO payment transactions for the legal entity; 0 when it has none. |
| dataset_amount_paid_gbp | Total amount_paid_gbp in the reporting table for the legal entity. |
| fo_amount_paid_gbp | Total FO accounting-currency amount, sign reversed, for the same in-scope transactions. |
| is_reconciled | 1 only when both row counts and both totals are equal; otherwise 0. |

Totals are held at six decimal places and compared exactly, with no rounding (assumed, Q-023), so a difference of 0.000001 shows as not reconciled. Payments with no amount are counted but add nothing to the total; a legal entity whose amounts are all missing shows a total of 0. Every column always has a value.
<!-- evidence: docs/design/DES-001.json#One row per legal entity found on either side; docs/design/DES-001.json#dataset_row_count; docs/design/DES-001.json#fo_row_count; docs/design/DES-001.json#decimal(38,6); docs/design/DES-001.json#is_reconciled; docs/design/MP-001.json#MOD-003; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Option A; docs/dev/CN-MOD-003.json#FULL OUTER JOINs; docs/dev/CN-MOD-003.json#Rows with a NULL ACCOUNTNUM are counted; docs/dev/CN-MOD-003.json#is_reconciled is 1 only when both counts and both totals are equal; docs/dev/CN-MOD-003.json#SUM ignores NULL amounts; docs/dev/CN-MOD-003.json#case-insensitive collation; docs/dev/CN-MOD-003.json#Every column is NOT NULL; docs/dev/CN-MOD-003.json#test entity with only out-of-scope FO rows and no dataset rows does not appear; docs/test/TCS-MOD-003.json#TC-003-005; docs/test/TCS-MOD-003.json#TC-003-006; docs/test/TCS-MOD-003.json#TC-003-007; docs/test/TCS-MOD-003.json#TC-003-008; docs/test/TCS-MOD-003.json#dataset_amount_paid_gbp; docs/test/TCS-MOD-003.json#fo_amount_paid_gbp -->

## Design decisions

| Decision | Recommendation | Status |
|---|---|---|
| ADR-001: View or persisted table, and how it refreshes | A persisted table, Layercake.fact_contact_payment, rebuilt in full from the rules view on every scheduled run, in one transaction. This keeps report queries off the external FO tables, picks up corrected and removed FO rows and contact country changes on every run, and gives the same result on a rerun. Provisional until data volumes and the load window are known (Q-025). | Proposed; the approved design follows the recommendation, and MOD-002 builds it. |
| ADR-002: How the reconciliation to FO is delivered | A reconciliation view in Layercake that the business can run at any time, including in production, to compare the dataset with FO for each legal entity and check the GBP assumption (Q-014). It is small and read only, and is meant to be run occasionally rather than by every report. | Proposed; the approved design follows the recommendation, and MOD-003 builds it. |

If volumes turn out to be large, ADR-001 records that the alternative of updating only the rows that changed would change only the load procedure, not the reporting table, the rules view or the reconciliation view.
<!-- evidence: docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#Option B; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#moving to C changes only the load procedure; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Option A; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#run occasionally; docs/design/DES-001.json#recommended option B; docs/design/DES-001.json#recommended option A; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003 -->
