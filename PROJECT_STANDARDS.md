# Project Standards: RICS Phase 2 (RICS)

| | |
|---|---|
| Inherits | Agent team base standards v1.7 (`standards/BASE_STANDARDS.md` in the framework) |
| Owner | Product Owner agent; changes approved by a named human |
| Created | 2026-10-08 |

Every agent on this project reads the base standards **and** this document. The base standards apply in full except where section 2 records an approved project-specific decision. An agent that cannot comply with either raises it to the Product Owner rather than deviating.

## 1. Project facts

| | |
|---|---|
| Project code (artefact IDs, object names) | `RICS` |
| Dev database | `RICS_Dev` |
| Test database | `RICS_Test` |
| Agent logins | `rics_agent_<role>` |
| Client / business owner | _to be completed at project set-up_ |
| Source systems | _to be completed by the Analyst_ |
| Repository | _to be completed_ |

## 2. Project-specific decisions and overrides

Only for things the base standards leave open or that the client requires differently (for example client naming rules, extra schemas, a different handover format). Each needs a named human's approval.

| ID | Base section | Decision | Reason | Approved by | Date |
|---|---|---|---|---|---|
| | | _none yet_ | | | |

## 3. Change log

| Date | Change | Approved by |
|---|---|---|
| 2026-10-08 | Project created from base standards v1.6 | pending |
| 2026-10-08 | Moved to base standards v1.7; Phase 1 imported as baseline `MIG-0002`, Phase 1 conventions kept (see below) | pending (Mike, by merging the PR) |

## Existing solution (baseline)

This project extends an existing solution. Its deployable scripts were imported as the baseline migration
`MIG-0002_bootstrap_phase1-layercake` (object files under `src/sql/<schema>/`, other scripts under `src/sql/baseline/`).
Overrides of the base standards, so that new code matches the solution and nothing that reads it breaks:

- Schemas (2.1): `Layercake`, `audit`, `etl`; new objects go in `Layercake`. `MIG-0000` still creates `stg`, `core` and `pres`, but they are not used.
- Table names (2.1): `^[a-z][a-z0-9_]*$`.
- Column names (2.1): `^[a-z][a-z0-9_]*$`.
- Load logging (3): load procedures call `Layercake.usp_etl_log_start`, `Layercake.usp_etl_log_end` instead of the `audit` procedures.
- Changing an existing object: the Developer changes it in place (a table through its change scripts); the
  module's down script restores the previous definition (base standards 3.1).
- The baseline is not rolled back: a database goes back to before its baseline by restoring a backup.

## Objects owned by other systems (external)

The project reads objects it does not own: other systems load or maintain them. They are listed in
`docs/sources/external_catalogue.json` with their columns, and their definitions (identifying literals masked) are under
`docs/sources/external/`. Agents use them as sources and to understand the existing data, and never create, alter, drop
or write to them (base standards 3.3). A change one would need goes to its owner through a human. In CI and on
the local dev and test databases they exist only as the stand-ins in `src/sql/ci/external_standins.sql`.
