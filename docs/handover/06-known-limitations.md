# Known limitations, assumptions and next steps: RICS Phase 2

## Assumptions awaiting confirmation

These rules rest on working assumptions recorded in the approved specification. They are built and tested as assumed and still need the business's confirmation, against real data where noted.

| Question | Working assumption |
|---|---|
| Q-014 | The accounting-currency amount (AMOUNTMST) is GBP in every FO legal entity, so amount_paid_gbp is labelled GBP. To be checked against real data through the per-legal-entity reconciliation (REQ-008). |
| Q-015 | Refunds, reversals and cancellations are recorded as payment transactions (type 15) with the opposite sign, and FO records payments received as negative amounts, so reversing the sign shows money received as positive and lets refunds net off. Cancelled payments are kept, and no other transaction type is included. To be checked against real data. |
| Q-021 | Layercake.brnz_contact holds every CRM contact with a contact number. If one were missing, its payments would be reported as corporate. To be checked against real data. |
| Q-022 | Where the country is 'Unknown' (contacts with no country or no matching country row, and all corporate payments), region and market reporting region also show 'Unknown'. The question is still open in the specification; the sign-off comment reads "Q-022 Unknown". |
| Q-023 | Amounts are kept at FO's six decimal places without rounding, so totals per legal entity reconcile to FO exactly. The question is still open in the specification; the sign-off comment reads "Q-023 keep FO precision". |
<!-- evidence: docs/specs/SPEC-001.json#Q-014; docs/specs/SPEC-001.json#Q-015; docs/specs/SPEC-001.json#Q-021; docs/specs/SPEC-001.json#Q-022; docs/specs/SPEC-001.json#Q-023; docs/specs/SPEC-001.json#Q-022 Unknown; docs/specs/SPEC-001.json#RULE-001; docs/design/DES-001.json#Q-022; docs/design/DES-001.json#Q-023 -->

## Known limitations

- **Payment date on 23 August 2021.** The specification describes the cut-off as a document date "on or before 2021-08-23". The solution applies the existing FO reporting rule exactly as that reporting writes it, as agreed at test design sign-off: a document date on 23 August 2021 that carries a time of day after midnight uses the transaction date instead. Such a payment is reported under its transaction date, not its document date.
- **Duplicate payment mode rows.** FO can hold more than one payment mode row with the same code in the same legal entity. Where it does, the name is taken from the row with the lowest FO record ID, so the same name is shown every time.
- **Duplicate country rows.** The country dimension does not enforce one row per country ID. Where a country ID appears more than once, the country, region and market are taken from the row with the lowest ID.
- **Company payments are not split.** Company payments are reported in full as corporate payments against the account they were posted to, until the business defines how they are split across memberships (see Scope in the Solution overview).
<!-- evidence: docs/dev/CN-MOD-001.json#follows synapse_fo.vwCustTrans literally; docs/test/TCS-MOD-001.json#DOCUMENTDATE time of day: follow vwCustTrans literally; docs/specs/SPEC-001.json#on or before 2021-08-23; docs/dev/CN-MOD-001.json#lowest CUSTPAYMMODETABLE.RECID; docs/dev/CN-MOD-001.json#lowest dim_country.id; docs/specs/SPEC-001.json#Q-006 -->

- **The read grant for report users waits for the reporting role's name.** No project record names the role the reporting tool uses, so the read grant on the reporting table is not part of the deployment. A person runs it separately, for the role the reporting tool already uses to read the Layercake fact tables, once that role's name is confirmed.
- **Error log entries are not linked to a load ID.** Errors from the payment load are written to audit.ErrorLog without a load ID, because Layercake loads log their runs in Layercake.etl_run_log rather than in the audit load log that the ID refers to. The failed run itself, with its error message, is in Layercake.etl_run_log (see Monitoring in the Runbook).
- **Row times show only the last rebuild.** Because the table is rebuilt in full on every run, created_at and updated_at give the time of the latest run for every row, not when a payment was first loaded or last changed.
- **A run that finds no payments empties the dataset.** The load always replaces the table with whatever the rules view returns. If the FO transaction source returned no in-scope payments on a run (for example, if it were empty), the dataset would be empty after that run, by design.
- **Run time grows with FO history.** Each run reads every payment transaction in FO, from an external table that this project cannot index, and rewrites every row of the dataset in one transaction. Run time and database log use therefore grow with the volume of FO history. No volumes or load window have been given yet (Q-025).
<!-- evidence: docs/dev/CN-MOD-002.json#Read grant not scripted as a file; docs/dev/CN-MOD-002.json#the role the reporting tool already uses to read the Layercake fact tables; docs/dev/CN-MOD-002.json#LoadId is NULL there; docs/design/DES-001.json#Equals created_at under a full rebuild; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#created_at and updated_at only show the last rebuild; docs/dev/CN-MOD-002.json#empties the dataset by design; docs/test/TCS-MOD-002.json#TC-002-006; docs/design/DES-001.json#The spec gives no volumes (Q-025); docs/dev/CN-MOD-002.json#log use grows with FO history -->

## Recommended next steps

- Confirm the working assumptions above. Q-014 can be checked on real data with the reconciliation view once it is delivered (MOD-003).
- Confirm the name of the reporting role, so that the read grant on the reporting table can be run.
- Provide data volumes for FO payment transactions and the time the payment load may take within the Layercake schedule (Q-025). The full-rebuild approach in ADR-001 is provisional until this is known.
- Complete the reconciliation view (MOD-003).
<!-- evidence: docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Q-014; docs/dev/CN-MOD-002.json#once the role name is confirmed; docs/design/DES-001.json#Q-025; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#provisional until Q-025; docs/design/MP-001.json#MOD-003 -->
