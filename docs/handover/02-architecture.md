# Architecture and data model: RICS Phase 2

## Architecture overview

The dataset is added to the existing Layercake solution and follows its conventions: objects in the Layercake schema with lower-case names. The solution is organised in these layers:

| Layer | Objects | Role |
|---|---|---|
| Sources (owned by other systems, read only) | synapse_fo.CUSTTRANS, synapse_fo.CUSTPAYMMODETABLE, CE.tblContact_Test_Records | FO customer transactions, FO payment modes and CRM test contacts. Read, never changed. |
| Existing Layercake objects (read without change) | Layercake.brnz_contact, Layercake.dim_country | CRM contacts with contact number, country and deleted flag; country, region and market reporting region. |
| New Layercake dataset | Layercake.vw_fact_contact_payment_source (built, MOD-001) | Applies every business rule of the dataset in one place, at one row per FO payment transaction. |

The business rules are defined once, in the rules view, so they can be tested apart from how the result is stored. In the approved design, the rules view is the only input to the reporting table Layercake.fact_contact_payment and its load procedure (MOD-002), and a reconciliation view compares the dataset with FO for each legal entity (MOD-003).
<!-- evidence: docs/design/DES-001.json#layers; docs/design/DES-001.json#Layercake.vw_fact_contact_payment_source; docs/design/MP-001.json#MOD-001; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#defined once -->

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

## Design decisions

| Decision | Recommendation | Status |
|---|---|---|
| ADR-001: View or persisted table, and how it refreshes | A persisted table, Layercake.fact_contact_payment, rebuilt in full from the rules view on every scheduled run, in one transaction. This keeps report queries off the external FO tables, picks up corrected and removed FO rows and contact country changes on every run, and gives the same result on a rerun. Provisional until data volumes and the load window are known (Q-025). | Proposed; the approved design follows the recommendation. |
| ADR-002: How the reconciliation to FO is delivered | A reconciliation view in Layercake that the business can run at any time, including in production, to compare the dataset with FO for each legal entity and check the GBP assumption (Q-014). | Proposed; the approved design follows the recommendation. |

Whichever option of ADR-001 applies, the business rules sit in the rules view built by MOD-001, so this module does not depend on how the dataset is stored.
<!-- evidence: docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#Option B; docs/design/adr/ADR-001-contact-payment-dataset-view-or-persisted-table-and-how-it-r.md#In every option; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Option A; docs/design/DES-001.json#recommended option B; docs/design/DES-001.json#recommended option A -->
