# BR-001 Financial reporting on what contacts pay

**Requested by:** Mike, 2026-10-08

We want to report on the financials: the amounts paid by a contact.

- Show the amounts each contact has paid.
- Include the payment method; this matters most.
- Include obvious segregation data so the figures can be split, for example the contact's country.

**Known complication:** a company can pay for several memberships. We are not currently sure how that data looks
in the sources or how it should be defined in the report (for example, whose payment it is and how it is split
across the memberships it covers). This needs to be investigated and defined before it is built.

## Answers to the Analyst's questions (Mike, 2026-10-08)

Mike reviewed the first draft of SPEC-001 and answered its open questions.

- **Q-001 Amount paid:** the payment transactions received on the contact's account in Finance & Operations (transaction type 15 'Payment'). Refunds, reversals and cancelled payments net off. Amounts show as positive figures.
- **Q-002 Payment method:** the method recorded on each payment transaction in Finance & Operations (PAYMMODE), named from the FO payment-mode table. Not the contact's preferred method in CRM.
- **Q-003 Currency:** both the currency paid in (with its currency code) and the GBP accounting-currency amount.
- **Q-004 Dates:** the FO transaction date, reported by calendar month and year. All payment history in FO.
- **Q-005 Country:** the contact's current CRM country, with the region and market reporting region of the existing country dimension. No other split fields for now. Contacts with no country show as unknown.
- **Q-006 Company payments:** until the split across memberships is defined, show company payments unsplit against the account they were posted to, flagged as corporate, so the report's totals match FO. They are not left out. Defining the split stays out of scope.
- **Q-007 Accounts:** accounts that match a CRM contact number (not deleted) are contacts. Every other customer account is reported as a company account under Q-006. All FO legal entities.
- **Q-008 No payment method:** shown as 'Unknown'.
- **Q-009 Possible duplicates:** reported as recorded in FO, not de-duplicated.
- **Q-010 Test records:** contacts flagged as test records are left out, as in the existing membership reporting.
- **Q-011 Payments outside FO:** out of scope (for example international payments recorded only in CRM).
- **Q-012 Delivery:** a queryable dataset in the Layercake schema for the existing reporting tool. The report layout is not part of this requirement.

## Second round of answers (Mike, 2026-10-09)

Mike reviewed the second draft of SPEC-001. Items marked **assumption** are working answers to be checked against the real data later. The spec should record them as assumptions, not as facts.

- **Test records (correction):** Layercake.brnz_contact is loaded from CE.vwContact, which already filters out test records. So test contacts can't be found through brnz_contact. Identify test accounts by matching the FO account number to CE.tblContact_Test_Records.apuk_contactnumber, and leave their payments out. They must not be reported as corporate payments.
- **Q-013 Migrated history:** use the same adjusted date as the existing FO reporting (synapse_fo.vwCustTrans): DOCUMENTDATE for transactions dated on or before 2021-08-23 (where DOCUMENTDATE is a real date, not 1900), and TRANSDATE otherwise.
- **Q-014 GBP amount (assumption):** AMOUNTMST is GBP in every FO legal entity. The reconciliation should show the totals per legal entity, so this can be checked.
- **Q-015 Refunds and cancellations (assumption):** they are recorded as TRANSTYPE 15 with the opposite sign and net off. No other transaction type is included. Cancelled payments (CANCELLEDPAYMENT) are not removed.
- **Q-016 Corporate country:** 'Unknown'.
- **Q-017 Grain:** one row per FO payment transaction.
- **Q-018 Shared contact numbers:** each payment is counted once. Any one of the matching contacts' countries may be used.
- **Q-019 Unnamed payment mode:** show the code itself.
- **Q-020 Refresh:** with the existing Layercake load schedule.
- **Q-021 Contact coverage (assumption):** Layercake.brnz_contact holds every CRM contact with a contact number.
