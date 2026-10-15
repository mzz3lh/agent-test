# Test summary and traceability: RICS Phase 2

## Test approach

Each module is tested against test conditions (TC-nnn-nnn) designed from the approved specification and the module's scope and acceptance criteria, independently of the code. Every test condition traces to a requirement and one of its acceptance criteria. The conditions are run as automated database tests, which set up their own sample data, so results do not depend on the contents of FO or CRM. Several conditions rest on the working assumptions listed in Known limitations (Q-014, Q-015, Q-022, Q-023) and test the rules as assumed.

For MOD-002, the tests run the load against sample data and check the stored table, the run log and the error log: first loads, reloads after FO rows were added, corrected or removed, a load with no in-scope rows, repeated loads, a forced failure, a contact's country change, totals per legal entity, and the call from the existing gold load. The read grant for report users is run separately by a person and is not covered by the tests.

For MOD-003, the tests set up sample FO transactions, test records and reporting-table rows and check the reconciliation view's output: legal entities that agree, row counts or totals that differ, legal entities found on one side only, missing account numbers and amounts, differences at the sixth decimal place, payments and refunds that net to zero, and duplicate FO payments and test records.

The developer's own unit tests also covered implementation details. For MOD-001, five tests covered how a document date on 23 August 2021 with a time of day is treated and how duplicate country, payment mode and contact rows are handled. For MOD-002, five tests covered the run log's layer, step name and row counts, the single shared time stamp per run, the run ID created when the load is run on its own, the failure path, and the payment load running last in the gold load. For MOD-003, three tests covered a legal entity whose amounts are all missing (it shows totals of 0 and reconciles), a legal entity with only out-of-scope FO transactions (it does not appear), and every column of the view always having a value. All thirteen passed.
<!-- evidence: docs/test/TCS-MOD-001.json#designed_from; docs/test/TCS-MOD-001.json#acceptance_criterion_id; docs/test/TCS-MOD-001.json#assumes Q-014; docs/test/TCS-MOD-001.json#assumes Q-015; docs/test/TCS-MOD-001.json#assumes Q-022; docs/test/TCS-MOD-001.json#assumes Q-023; docs/test/TCS-MOD-002.json#designed_from; docs/test/TCS-MOD-002.json#assumes Q-014; docs/test/TCS-MOD-002.json#The read grant for the reporting role is a script for a human to run and is not tested here; docs/test/TCS-MOD-003.json#designed_from; docs/test/TCS-MOD-003.json#TC-003-001; docs/test/TCS-MOD-003.json#TC-003-010; BASE_STANDARDS.md#Separation; docs/dev/CN-MOD-001.json#unit_tests; docs/dev/CN-MOD-002.json#unit_tests; docs/dev/CN-MOD-003.json#unit_tests; docs/dev/CN-MOD-003.json#3 unit test(s) -->

## Results by module

| Module | Test run | Environment | Conditions | Passed | Failed | Skipped | Verdict |
|---|---|---|---|---|---|---|---|
| MOD-001 Contact payment rules view | 2026-10-13 | Test | 35 | 35 | 0 | 0 | Pass |
| MOD-002 Contact payment table, full-rebuild load and schedule hook | 2026-10-15 | Test | 16 | 16 | 0 | 0 | Pass |
| MOD-003 Per-legal-entity reconciliation view | 2026-10-15 | Test | 10 | 10 | 0 | 0 | Pass |

MOD-001 met all six of its requirements (REQ-001 to REQ-006). MOD-002 met its three requirements (REQ-006, REQ-007 and REQ-008). MOD-003 met its requirement, REQ-008, through its remaining acceptance criterion, the reconciliation view (AC-008-03). Testing of all three modules raised no defects.
<!-- evidence: docs/test/TR-MOD-001-1.json#TR-MOD-001-1; docs/test/TR-MOD-001-1.json#requirement_status; docs/test/TR-MOD-001-1.json#verdict; docs/test/TR-MOD-002-1.json#TR-MOD-002-1; docs/test/TR-MOD-002-1.json#2026-10-15T15:31:48Z; docs/test/TR-MOD-002-1.json#requirement_status; docs/test/TR-MOD-002-1.json#verdict; docs/test/TR-MOD-003-1.json#TR-MOD-003-1; docs/test/TR-MOD-003-1.json#2026-10-15T17:00:51Z; docs/test/TR-MOD-003-1.json#requirement_status; docs/test/TR-MOD-003-1.json#verdict; docs/design/MP-001.json#AC-008-03 -->

## Traceability

### MOD-001

| Test condition | Requirement | Acceptance criterion | What it checks | Result |
|---|---|---|---|---|
| TC-001-001 | REQ-001 | AC-001-01 | Only payment transactions (type 15) are in scope | Passed |
| TC-001-002 | REQ-001 | AC-001-02 | Row count per legal entity matches in-scope FO rows | Passed |
| TC-001-003 | REQ-001, REQ-005 | AC-001-03 | Each payment appears once when the account matches two contacts | Passed |
| TC-001-004 | REQ-001 | AC-001-04 | Test-account payments are left out in every legal entity | Passed |
| TC-001-005 | REQ-001 | AC-001-04 | A test record with no contact number excludes nothing else | Passed |
| TC-001-006 | REQ-001 to REQ-006 | AC-001-02 | A payment with missing optional values is carried through, not dropped | Passed |
| TC-001-007 | REQ-001 | AC-001-05 | A cancelled payment is kept (assumed, Q-015) | Passed |
| TC-001-008 | REQ-001 | AC-001-06 | Identical payments with different record IDs are both kept | Passed |
| TC-001-009 | REQ-001 | AC-001-07 | All legal entities and old dates are included | Passed |
| TC-001-010 | REQ-002 | AC-002-01 | A EUR payment shows positive currency and GBP amounts (assumed, Q-014) | Passed |
| TC-001-011 | REQ-002 | AC-002-01 | Amounts keep six decimal places without rounding (assumed, Q-023) | Passed |
| TC-001-012 | REQ-002 | AC-002-02 | A refund shows negative and nets off against a payment (assumed, Q-015) | Passed |
| TC-001-013 | REQ-002 | AC-002-03 | A GBP payment shows positive amounts | Passed |
| TC-001-014 | REQ-003 | AC-003-01 | Payment method is named from the legal entity's payment mode table | Passed |
| TC-001-015 | REQ-003 | AC-003-02 | A missing, empty or blank payment mode shows 'Unknown' | Passed |
| TC-001-016 | REQ-003 | AC-003-03 | An unmatched or unnamed payment mode shows its code | Passed |
| TC-001-017 | REQ-003 | AC-003-04 | The payment method name depends on the legal entity | Passed |
| TC-001-018 | REQ-004 | AC-004-01 | A document date before the cut-off is used | Passed |
| TC-001-019 | REQ-004 | AC-004-02 | A document date on the cut-off date is used | Passed |
| TC-001-020 | REQ-004 | AC-004-03 | A document date after the cut-off uses the transaction date | Passed |
| TC-001-021 | REQ-004 | AC-004-04 | A 1900 or missing document date uses the transaction date | Passed |
| TC-001-022 | REQ-004 | AC-004-04 | Any 1900 document date is ignored, but 1901 is used | Passed |
| TC-001-023 | REQ-004 | AC-004-05 | Year and month are calendar values of the payment date | Passed |
| TC-001-024 | REQ-005 | AC-005-01 | A payment on a current contact's account is a contact payment | Passed |
| TC-001-025 | REQ-005 | AC-005-02 | An unmatched account gives one unsplit corporate payment | Passed |
| TC-001-026 | REQ-005 | AC-005-03 | An account matching only a deleted contact is corporate | Passed |
| TC-001-027 | REQ-005 | AC-005-03 | A deleted duplicate contact is ignored for attribution and country | Passed |
| TC-001-028 | REQ-005 | AC-005-04 | The contact match applies in any legal entity | Passed |
| TC-001-029 | REQ-005 | AC-005-05 | Contact plus corporate totals equal the legal entity total | Passed |
| TC-001-030 | REQ-006 | AC-006-01 | A contact payment shows country, region and market | Passed |
| TC-001-031 | REQ-006 | AC-006-02 | A contact without a known country shows 'Unknown' (assumed, Q-022) | Passed |
| TC-001-032 | REQ-006 | AC-006-03 | A corporate payment shows 'Unknown' country, region and market (assumed, Q-022) | Passed |
| TC-001-033 | REQ-006 | AC-006-03 | 'Unknown' values have exact case and no padding (assumed, Q-022) | Passed |
| TC-001-034 | REQ-006 | AC-006-04 | A shared contact number gives one row with one matching country | Passed |
| TC-001-035 | REQ-006 | AC-006-04 | A shared contact number uses the country of the lowest contact ID | Passed |
<!-- evidence: docs/test/TCS-MOD-001.json#TC-001-001; docs/test/TCS-MOD-001.json#TC-001-035; docs/test/TR-MOD-001-1.json#TC-001-001; docs/test/TR-MOD-001-1.json#TC-001-035; docs/design/MP-001.json#AC-006-04 -->

### MOD-002

| Test condition | Requirement | Acceptance criterion | What it checks | Result |
|---|---|---|---|---|
| TC-002-001 | REQ-007 | AC-007-01 | The load stores a contact and a corporate payment with every column, the run ID and audit times | Passed |
| TC-002-002 | REQ-007 | AC-007-01 | The table has exactly the designed columns, all named in lower case | Passed |
| TC-002-003 | REQ-007 | AC-007-02 | A payment added in FO after a load appears after the next load | Passed |
| TC-002-004 | REQ-007 | AC-007-02 | An FO correction to a loaded payment is restated on the next load | Passed |
| TC-002-005 | REQ-007 | AC-007-02 | A payment removed from FO disappears on the next load | Passed |
| TC-002-006 | REQ-007 | AC-007-02 | A load with no in-scope payments leaves the dataset empty | Passed |
| TC-002-007 | REQ-007 | AC-007-03 | A second load with unchanged sources leaves row counts and totals per legal entity unchanged | Passed |
| TC-002-008 | REQ-007 | AC-007-03 | A rerun keeps one row per payment, all stamped with the latest run ID | Passed |
| TC-002-009 | REQ-007 | AC-007-04 | A successful load is logged as 'Success' with its start, finish and rows inserted and deleted | Passed |
| TC-002-010 | REQ-007, REQ-008 | AC-007-04 | A failing load passes the error back, logs it and a 'Failed' run, and keeps the previous dataset | Passed |
| TC-002-011 | REQ-006 | AC-006-05 | A contact's country change restates all the contact's payments on the next load | Passed |
| TC-002-012 | REQ-008 | AC-008-01 | Row count and GBP total for a legal entity match FO, with the test account left out (assumed, Q-014) | Passed |
| TC-002-013 | REQ-008 | AC-008-01 | A payment with missing account, amounts, currency and dates is loaded, not rejected | Passed |
| TC-002-014 | REQ-008 | AC-008-02 | Currency totals per legal entity and currency equal the FO totals with the sign reversed | Passed |
| TC-002-015 | REQ-008 | AC-008-02 | Amounts keep six decimal places without rounding | Passed |
| TC-002-016 | REQ-007 | AC-007-02 | The existing gold load runs the payment load once, with its run ID, after every dimension load | Passed |
<!-- evidence: docs/test/TCS-MOD-002.json#TC-002-001; docs/test/TCS-MOD-002.json#TC-002-016; docs/test/TCS-MOD-002.json#assumes Q-014; docs/test/TR-MOD-002-1.json#TC-002-001; docs/test/TR-MOD-002-1.json#TC-002-016; docs/design/MP-001.json#AC-006-05 -->

### MOD-003

| Test condition | Requirement | Acceptance criterion | What it checks | Result |
|---|---|---|---|---|
| TC-003-001 | REQ-008 | AC-008-03 | A legal entity reconciles, with the test account and other transaction types left out of the FO side and a cancelled payment and a corporate account kept (assumed, Q-014) | Passed |
| TC-003-002 | REQ-008 | AC-008-03 | Two legal entities are reconciled separately, one row each, using the accounting-currency amount (assumed, Q-014) | Passed |
| TC-003-003 | REQ-008 | AC-008-03 | Row counts that differ while totals agree show as not reconciled | Passed |
| TC-003-004 | REQ-008 | AC-008-03 | Totals that differ while row counts agree show as not reconciled | Passed |
| TC-003-005 | REQ-008 | AC-008-03 | A legal entity with FO payments but none in the dataset still shows, with the dataset side 0 | Passed |
| TC-003-006 | REQ-008 | AC-008-03 | A legal entity with dataset rows but no FO payments still shows, with the FO side 0 | Passed |
| TC-003-007 | REQ-008 | AC-008-03 | FO rows with a missing account number or amount are counted, and a test record with no contact number excludes nothing else | Passed |
| TC-003-008 | REQ-008 | AC-008-03 | Totals are compared at six decimal places without rounding (assumed, Q-023) | Passed |
| TC-003-009 | REQ-008 | AC-008-03 | A payment and a refund that net to zero reconcile at 0 | Passed |
| TC-003-010 | REQ-008 | AC-008-03 | Identical FO payments are both counted, and a test account listed twice neither multiplies nor lets through FO rows | Passed |
<!-- evidence: docs/test/TCS-MOD-003.json#TC-003-001; docs/test/TCS-MOD-003.json#TC-003-010; docs/test/TCS-MOD-003.json#assumes Q-014; docs/test/TCS-MOD-003.json#assumes Q-023; docs/test/TR-MOD-003-1.json#TC-003-001; docs/test/TR-MOD-003-1.json#TC-003-010; docs/design/MP-001.json#AC-008-03 -->
