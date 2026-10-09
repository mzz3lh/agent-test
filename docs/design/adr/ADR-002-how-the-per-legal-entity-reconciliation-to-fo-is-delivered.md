# ADR-002: How the per-legal-entity reconciliation to FO is delivered

| | |
|---|---|
| Status | proposed |
| Date | 2026-10-09 |
| Requirement IDs | REQ-008 |
| Decided by | pending: a human decides at the architecture validation gate |

## Context
REQ-008 asks for the dataset's figures to reconcile to FO for each legal entity, so the business can confirm that totals match FO and can check the working assumption that AMOUNTMST is GBP in every legal entity (Q-014). AC-008-03 says a reconciliation query can list, per legal entity, the dataset's row count and GBP total next to the FO count and -1 times the FO AMOUNTMST total. The check has to be repeatable on real data after go-live, not only in test.

## Options
### Option A: A. Reconciliation view in Layercake
Layercake.vw_contact_payment_reconciliation lists, for each legal entity, the dataset's row count and amount_paid_gbp total next to the FO count and -1 times the FO AMOUNTMST total for TRANSTYPE 15 rows not on test accounts, with a flag showing whether both sides agree. The FO side reads the FO and CE sources directly, separately from the dataset's own rules.

Trade-offs: The business and support staff can run the check at any time from the reporting tool, including on production after go-live, which is how Q-014 is to be confirmed. One more small object to build, grant and maintain. Each query reads the external FO table for all history, but it is run occasionally, not by every report.

### Option B: B. Test and runbook query only
There is no new object. The reconciliation is a Tester query, run in tests, and a documented query in the runbook that support staff run by hand.

Trade-offs: Nothing extra to deploy or secure. The check is not available to the business in the reporting tool. It relies on someone copying the runbook query correctly, and it is not version-controlled as a database object, so it can drift from the dataset's scope rules.

## Recommendation
Option A: A. Reconciliation view in Layercake. REQ-008 exists so the business can confirm the totals and test the GBP assumption on real data. That needs a check they can run after go-live, not only one inside the test suite. A view is small, read-only and cheap to maintain. It computes the FO side independently of the dataset's rules view, so it is a real cross-check.

## Decision
Pending: filled in by a human at the architecture validation gate.

## Consequences
MOD-003 adds Layercake.vw_contact_payment_reconciliation, depends on MOD-002, and carries AC-008-03. It needs SELECT granted to the reporting role (scripted for a human). If B is chosen, MOD-003 is dropped, AC-008-03 moves to MOD-002 as a test query, and the runbook carries the query.
