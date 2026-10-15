# Data lineage: RICS Phase 2

## Sources

| Source | Owner | What is used |
|---|---|---|
| synapse_fo.CUSTTRANS | FO (external, read only) | Customer transactions: legal entity, record ID, transaction type, account number, amounts in the currency paid and accounting currency, currency code, payment mode, document and transaction dates. |
| synapse_fo.CUSTPAYMMODETABLE | FO (external, read only) | Payment mode names, per legal entity and payment mode code. |
| CE.tblContact_Test_Records | CRM (external, read only) | Contact numbers of test contacts, used only to leave their payments out. |
| Layercake.brnz_contact | Existing Layercake object, loaded from CRM | Contact number, current country and deleted flag of each CRM contact. |
| Layercake.dim_country | Existing Layercake object | Country name, region and market reporting region. |

None of these sources is changed by the solution. The rules view reads all five. The reconciliation view reads synapse_fo.CUSTTRANS and CE.tblContact_Test_Records directly, next to the reporting table.
<!-- evidence: docs/design/DES-001.json#Sources (external, read-only); docs/design/DES-001.json#Layercake bronze and dimensions (existing); docs/specs/SPEC-001.json#CRM; docs/design/MP-001.json#without changing them; docs/design/MP-001.json#The FO side is computed directly from synapse_fo.CUSTTRANS -->

## Source-to-target mappings

### Layercake.vw_fact_contact_payment_source (MOD-001)

Rows: every synapse_fo.CUSTTRANS row with transaction type 15, all legal entities and dates, cancelled payments included, except rows whose account number equals a contact number in CE.tblContact_Test_Records.

| Target column | Source | Rule |
|---|---|---|
| legal_entity | CUSTTRANS.DATAAREAID | As recorded. |
| fo_transaction_recid | CUSTTRANS.RECID | As recorded. |
| account_number | CUSTTRANS.ACCOUNTNUM | As recorded. |
| contact_number | brnz_contact.Rics_contactno | Contact number of the matched current contact (lowest contact ID where several match); empty for corporate payments. |
| is_corporate | brnz_contact.Rics_contactno and _is_deleted | 0 when the account number matches a contact that is not deleted; otherwise 1. |
| payment_date | CUSTTRANS.DOCUMENTDATE, TRANSDATE | Document date when on or before 2021-08-23 and not in 1900; otherwise transaction date. |
| payment_year | payment_date | Calendar year. |
| payment_month | payment_date | Calendar month (1 to 12). |
| amount_paid_currency | CUSTTRANS.AMOUNTCUR | Multiplied by -1; six decimal places, no rounding (assumed, Q-023). |
| currency_code | CUSTTRANS.CURRENCYCODE | As recorded. |
| amount_paid_gbp | CUSTTRANS.AMOUNTMST | Multiplied by -1; six decimal places, no rounding. Taken to be GBP (assumed, Q-014). |
| payment_method_code | CUSTTRANS.PAYMMODE | As recorded; 'Unknown' when missing or blank. |
| payment_method | CUSTPAYMMODETABLE.NAME | Matched on payment mode code and the transaction's legal entity. 'Unknown' when there is no code; the code itself when there is no match or the name is missing or blank. |
| country_name | dim_country.country_name | Matched contact's current country (brnz_contact.rics_countryid to dim_country.country_id); 'Unknown' for corporate payments, contacts with no country, or no match. |
| region_name | dim_country.region_name | Same lookup; 'Unknown' wherever country_name is 'Unknown' (assumed, Q-022). |
| market_reporting_region | dim_country.market_reporting_region | Same lookup; 'Unknown' wherever country_name is 'Unknown' (assumed, Q-022). |
<!-- evidence: docs/specs/SPEC-001.json#REQ-001; docs/specs/SPEC-001.json#RULE-005; docs/specs/SPEC-001.json#RULE-006; docs/specs/SPEC-001.json#RULE-007; docs/specs/SPEC-001.json#RULE-008; docs/specs/SPEC-001.json#Layercake.fact_contact_payment.payment_date; docs/specs/SPEC-001.json#Layercake.brnz_contact._is_deleted; docs/design/DES-001.json#rics_countryid; docs/design/DES-001.json#lowest ContactId; docs/design/DES-001.json#Q-022; docs/design/DES-001.json#Q-023 -->

### Layercake.fact_contact_payment (MOD-002)

Rows: on every run, exactly the rows the rules view returns at that moment, one per payment. The table is emptied and refilled in one transaction, so a payment removed from FO since the last run is no longer in it, and a corrected payment or a contact's changed country is restated for all history.

| Target column | Source | Rule |
|---|---|---|
| legal_entity to market_reporting_region (16 columns) | The column of the same name in Layercake.vw_fact_contact_payment_source | Copied unchanged; all business rules are applied in the rules view (see the mapping above). |
| run_id | The load run | The run ID passed in by the Layercake load, or a newly created one when the load is run on its own. |
| created_at | The load run | One UTC time for every row written by the run. |
| updated_at | The load run | Same value as created_at. |
<!-- evidence: docs/design/DES-001.json#Layercake.fact_contact_payment; docs/design/DES-001.json#Layercake.usp_load_fact_contact_payment; docs/design/DES-001.json#Equals created_at under a full rebuild; docs/dev/CN-MOD-002.json#stamping @run_id; docs/dev/CN-MOD-002.json#generates a run id when called standalone; docs/test/TCS-MOD-002.json#TC-002-001; docs/test/TCS-MOD-002.json#TC-002-004; docs/test/TCS-MOD-002.json#TC-002-005; docs/test/TCS-MOD-002.json#TC-002-011; docs/specs/SPEC-001.json#AC-006-05 -->

### Layercake.vw_contact_payment_reconciliation (MOD-003)

Rows: one per legal entity found in the reporting table or among the in-scope FO transactions. In-scope FO transactions are synapse_fo.CUSTTRANS rows with transaction type 15, all dates, cancelled payments included, except rows whose account number equals a contact number in CE.tblContact_Test_Records. These are worked out here directly, not taken from the rules view.

| Target column | Source | Rule |
|---|---|---|
| legal_entity | fact_contact_payment.legal_entity and CUSTTRANS.DATAAREAID | The legal entity from either side; codes differing only in case count as one. |
| dataset_row_count | Layercake.fact_contact_payment | Number of rows for the legal entity; 0 when there are none. |
| dataset_amount_paid_gbp | fact_contact_payment.amount_paid_gbp | Total for the legal entity, six decimal places, no rounding; missing amounts add nothing; 0 when there are no rows. |
| fo_row_count | synapse_fo.CUSTTRANS | Number of in-scope transactions for the legal entity, including any with no account number; 0 when there are none. |
| fo_amount_paid_gbp | CUSTTRANS.AMOUNTMST | Total for the legal entity multiplied by -1; six decimal places, no rounding (assumed, Q-023); missing amounts add nothing; 0 when there are none. Taken to be GBP (assumed, Q-014). |
| is_reconciled | The four figures above | 1 when dataset_row_count equals fo_row_count and dataset_amount_paid_gbp equals fo_amount_paid_gbp; otherwise 0. |
<!-- evidence: docs/design/MP-001.json#MOD-003; docs/design/DES-001.json#One row per legal entity found on either side; docs/design/DES-001.json#decimal(38,6); docs/specs/SPEC-001.json#AC-008-03; docs/dev/CN-MOD-003.json#FULL OUTER JOINs; docs/dev/CN-MOD-003.json#cancelled payments kept; docs/dev/CN-MOD-003.json#Rows with a NULL ACCOUNTNUM are counted; docs/dev/CN-MOD-003.json#The total is -1 * SUM(AMOUNTMST); docs/dev/CN-MOD-003.json#SUM ignores NULL amounts; docs/dev/CN-MOD-003.json#case-insensitive collation; docs/dev/CN-MOD-003.json#is_reconciled is 1 only when both counts and both totals are equal; docs/test/TCS-MOD-003.json#TC-003-001; docs/test/TCS-MOD-003.json#TC-003-002; docs/test/TCS-MOD-003.json#TC-003-008 -->
