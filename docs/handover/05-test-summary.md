# Test summary and traceability: RICS Phase 2

## Test approach

Each module is tested against test conditions (TC-nnn-nnn) designed from the approved specification and the module's scope and acceptance criteria, independently of the code. Every test condition traces to a requirement and one of its acceptance criteria. The conditions are run as automated database tests, which set up their own sample data, so results do not depend on the contents of FO or CRM. Several conditions rest on the working assumptions listed in Known limitations (Q-014, Q-015, Q-022, Q-023) and test the rules as assumed.

The developer's own unit tests also covered five implementation details of MOD-001 (how a document date on 23 August 2021 with a time of day is treated, and how duplicate country, payment mode and contact rows are handled); all five passed.
<!-- evidence: docs/test/TCS-MOD-001.json#designed_from; docs/test/TCS-MOD-001.json#acceptance_criterion_id; docs/test/TCS-MOD-001.json#assumes Q-014; docs/test/TCS-MOD-001.json#assumes Q-015; docs/test/TCS-MOD-001.json#assumes Q-022; docs/test/TCS-MOD-001.json#assumes Q-023; BASE_STANDARDS.md#Separation; docs/dev/CN-MOD-001.json#unit_tests -->

## Results by module

| Module | Test run | Environment | Conditions | Passed | Failed | Skipped | Verdict |
|---|---|---|---|---|---|---|---|
| MOD-001 Contact payment rules view | 2026-10-13 | Test | 35 | 35 | 0 | 0 | Pass |

MOD-001 met all six of its requirements (REQ-001 to REQ-006). Testing raised no defects.
<!-- evidence: docs/test/TR-MOD-001-1.json#TR-MOD-001-1; docs/test/TR-MOD-001-1.json#requirement_status; docs/test/TR-MOD-001-1.json#verdict -->

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
