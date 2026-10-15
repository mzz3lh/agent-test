# Solution overview: RICS Phase 2

## Purpose

RICS Phase 2 adds a contact payment dataset to the existing Layercake solution. It shows what contacts have paid: one row for each payment transaction in Finance & Operations (FO), the finance system. Each row gives the amount paid as a positive figure in the currency paid and in GBP, the payment method recorded on the transaction, the payment date with its calendar month and year, whether the payment is a contact or a corporate payment, and the contact's current country, region and market reporting region from the contact system (CRM).

Payment method is the attribute that matters most to the business. Accounts that match a current CRM contact number are treated as contacts. Every other account is reported unsplit as a corporate payment, so the dataset's totals match FO.

Throughout this pack, requirements are numbered REQ-nnn, the business rules within them RULE-nnn and their acceptance criteria AC-nnn-nn. Build modules are MOD-nnn, test conditions TC-nnn-nnn, open questions Q-nnn, architecture decision records ADR-nnn and deployment scripts (migrations) MIG-nnnn.
<!-- evidence: docs/specs/SPEC-001.json#summary; docs/specs/SPEC-001.json#REQ-003; docs/design/DES-001.json#overview; BASE_STANDARDS.md#Identifiers and traceability -->

## Scope

**In scope**

- Every FO payment transaction (transaction type 15) on customer accounts, in all FO legal entities and for all history, with no date limit.
- Refunds, reversals and cancelled payments recorded as payment transactions. They are kept and net off through their sign.
- Payments on contact accounts and on corporate accounts.
- A reporting table in the Layercake schema, refreshed with the existing Layercake load schedule.
- A reconciliation view that compares the dataset with FO for each legal entity.

**Out of scope**

- Payments on test accounts. They are left out entirely.
- Splitting company payments across the memberships they cover. This stays out of scope until the business defines the split (Q-006).
- Payments recorded outside FO, for example international payments recorded only in CRM (Q-011).
- The contact's preferred payment method in CRM. Only the method recorded on the FO transaction is used.
- The report layout. The solution delivers a dataset for the existing reporting tool.

The solution is built in three modules: the rules view that applies every business rule (MOD-001), the reporting table with its full-rebuild load hooked into the existing Layercake schedule (MOD-002), and a reconciliation view that compares the dataset with FO for each legal entity (MOD-003). This pack covers all three.
<!-- evidence: docs/specs/SPEC-001.json#RULE-002; docs/specs/SPEC-001.json#RULE-003; docs/specs/SPEC-001.json#RULE-005; docs/specs/SPEC-001.json#RULE-020; docs/specs/SPEC-001.json#RULE-021; docs/specs/SPEC-001.json#The report layout is not part of this requirement; docs/specs/SPEC-001.json#Q-006; docs/specs/SPEC-001.json#Q-011; docs/specs/SPEC-001.json#REQ-003; docs/design/MP-001.json#MOD-001; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003; docs/design/DES-001.json#Layercake.vw_contact_payment_reconciliation -->

## Requirements delivered

The table shows the requirements delivered and the modules that deliver them. All rules for REQ-001 to REQ-006 are applied in the rules view built by MOD-001. MOD-002 stores the view's output in the reporting table Layercake.fact_contact_payment and refreshes it with the existing Layercake load. MOD-003 adds the reconciliation view Layercake.vw_contact_payment_reconciliation, which lists for each legal entity the dataset's row count and GBP total next to the same figures taken directly from FO, and shows whether they agree. All three modules passed testing with every requirement met (see the Test summary). Report users read the dataset from the reporting table and the check from the reconciliation view, once their read access has been granted (see Known limitations); the rules view itself is not made available to them.

| Requirement | What it delivers | Module | Status |
|---|---|---|---|
| REQ-001 | One row per FO payment transaction (type 15), all legal entities and history, test accounts left out, no de-duplication | MOD-001 | Met |
| REQ-002 | Amount paid as a positive figure in the currency paid (with currency code) and in GBP; refunds show negative and net off | MOD-001 | Met |
| REQ-003 | Payment method code and name from FO, with 'Unknown' and code fallbacks | MOD-001 | Met |
| REQ-004 | Payment date (the adjusted FO date used by existing FO reporting) with calendar year and month | MOD-001 | Met |
| REQ-005 | Each payment attributed to a contact or flagged as corporate, counted once | MOD-001 | Met |
| REQ-006 | The contact's current country, region and market reporting region, with 'Unknown' fallbacks; a change of country restates all the contact's past payments on the next load | MOD-001, MOD-002 | Met |
| REQ-007 | A queryable dataset in the Layercake schema with lower-case names, refreshed with the existing Layercake load, the same result on a rerun, and each run logged | MOD-002 | Met |
| REQ-008 | Row counts and totals per legal entity reconcile to FO, with a reconciliation view to check this at any time | MOD-002 (AC-008-01, AC-008-02); MOD-003 (AC-008-03) | Met |
<!-- evidence: docs/design/MP-001.json#MOD-001; docs/design/MP-001.json#MOD-002; docs/design/MP-001.json#MOD-003; docs/design/MP-001.json#AC-008-03; docs/test/TR-MOD-001-1.json#requirement_status; docs/test/TR-MOD-002-1.json#requirement_status; docs/test/TR-MOD-003-1.json#requirement_status; docs/specs/SPEC-001.json#REQ-001; docs/specs/SPEC-001.json#REQ-002; docs/specs/SPEC-001.json#REQ-003; docs/specs/SPEC-001.json#REQ-004; docs/specs/SPEC-001.json#REQ-005; docs/specs/SPEC-001.json#REQ-006; docs/specs/SPEC-001.json#AC-006-05; docs/specs/SPEC-001.json#Delivery and refresh; docs/specs/SPEC-001.json#Reconciliation to FO per legal entity; docs/specs/SPEC-001.json#RULE-022; docs/design/DES-001.json#is not granted to report users; docs/dev/CN-MOD-002.json#Read grant not scripted as a file; docs/dev/CN-MOD-003.json#Read grant not scripted as a file; docs/design/adr/ADR-002-how-the-per-legal-entity-reconciliation-to-fo-is-delivered.md#Option A -->
