# Glossary: RICS Phase 2

## Terms

| Term | Meaning |
|---|---|
| FO | Dynamics 365 Finance & Operations, the finance system. Its customer transactions are read from synapse_fo.CUSTTRANS. |
| CRM | Dynamics 365 Customer Engagement, the contact system. Contacts are read from Layercake.brnz_contact, which is loaded from CRM. |
| Layercake | The existing solution and database schema that the contact payment dataset is added to. |
| Layercake load | The existing scheduled load of the Layercake solution, started through Layercake.usp_run_daily_load, which runs the bronze, silver and gold loads under one run ID. |
| Legal entity | The FO company that holds the transaction. |
| Payment transaction | An FO customer transaction of type 15 ('Payment'). Refunds and reversals recorded as type 15 with the opposite sign are included and net off. |
| Contact account | An FO customer account whose account number equals the contact number of at least one current (not deleted) CRM contact. |
| Contact payment | A payment on a contact account. |
| Corporate payment | A payment on any FO customer account that is not a contact account and not a test account. It is reported unsplit against the account it was posted to. |
| Test account | An FO customer account whose account number equals a CRM test contact number. Its payments are left out. |
| Payment date | The adjusted FO date used by the existing FO reporting: the document date when it is on or before 2021-08-23 and not in 1900, otherwise the transaction date. |
| Accounting currency amount | The FO amount in the legal entity's accounting currency, taken to be GBP in every legal entity (assumed, Q-014). |
| Payment method | The payment mode recorded on the FO transaction, with its name from the FO payment mode table for the same legal entity. |
| Market reporting region | An attribute of each country, held with its region in the existing country dimension (Layercake.dim_country). |
| Rules view | Layercake.vw_fact_contact_payment_source, the view that applies every business rule of the dataset. |
| Reporting table | Layercake.fact_contact_payment, the table that holds the dataset for the reporting tool. |
| Reconciliation view | Layercake.vw_contact_payment_reconciliation, the view that lists for each legal entity the dataset's row count and GBP total next to the same figures worked out directly from FO. |
| Reconciled | In the reconciliation view, a legal entity whose row counts and GBP totals are equal on both sides (is_reconciled = 1). |
| Full rebuild | The way the reporting table is loaded: on every run its whole content is replaced with the rules view's current output, in one transaction. |
| Run ID | The identifier of one load run. Every row the run writes, and its entry in the run log, carry it. |
| Run log | Layercake.etl_run_log, the existing Layercake record of each load run's start, finish, row counts and outcome. |
| Error log | audit.ErrorLog, where errors raised during a load are recorded. |
| Migration | A numbered deployment script with a partner script that reverses it (up and down), for example MIG-0003. |
| REQ, RULE, AC | Requirement, business rule and acceptance criterion in the approved specification. |
| MOD | A build module: a part of the solution built and tested on its own. |
| TC | A test condition: one tested case, traced to a requirement and acceptance criterion. |
| Q | A question recorded in the specification or design, open or answered. |
| ADR | Architecture decision record: a design choice with its options and recommendation. |
<!-- evidence: docs/specs/SPEC-001.json#Payment transaction; docs/specs/SPEC-001.json#Contact account; docs/specs/SPEC-001.json#Corporate payment; docs/specs/SPEC-001.json#Test account; docs/specs/SPEC-001.json#Payment date; docs/specs/SPEC-001.json#Accounting currency amount; docs/specs/SPEC-001.json#Legal entity; docs/specs/SPEC-001.json#RULE-008; docs/design/DES-001.json#market_reporting_region; docs/design/DES-001.json#existing Layercake solution; docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/DES-001.json#Layercake.fact_contact_payment; docs/design/DES-001.json#Layercake.vw_contact_payment_reconciliation; docs/design/DES-001.json#is_reconciled; docs/design/MP-001.json#MOD-003; docs/dev/CN-MOD-003.json#is_reconciled is 1 only when both counts and both totals are equal; docs/design/DES-001.json#Layercake.usp_run_daily_load is the scheduled entry point; docs/design/DES-001.json#Load logging; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#Option B; docs/dev/CN-MOD-002.json#stamping @run_id; docs/dev/CN-MOD-001.json#MIG-0003; BASE_STANDARDS.md#Identifiers and traceability -->
