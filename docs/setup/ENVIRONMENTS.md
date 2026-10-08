# Environments: RICS Phase 2

Source of truth: `config/project.yaml`. Who can do what in each environment: `ACCESS_MATRIX.md` (generated).

| Environment | Database | Platform | Data | Agents | Lifecycle |
|---|---|---|---|---|---|
| dev | `RICS_Dev` | Local SQL Server 2016 SP1 or later, bound to localhost | Synthetic or masked only | Developer builds; Analyst, Architect and Product Owner see metadata only; Tester reads data | Long-lived, disposable, can be rebuilt from the repo at any time |
| test | `RICS_Test` | Same server as dev | Synthetic only | Tester deploys the module commit and runs tests; Product Owner sees metadata | Rebuilt clean from `main` + the module commit for each test run |
| prod | client-specific | client-specific | Real | None | Outside this system. Humans deploy |

## Rules
- No agent has a connection string, credential or network route to production.
- Restoring any client data into dev or test needs written human approval and a masking step first.
- Several projects can share one local SQL Server: each has its own databases (`<CODE>_Dev`, `<CODE>_Test`) and its own agent logins (`<code>_agent_<role>`), so one project's agents cannot reach another's databases.
- tSQLt and the `test_*` schemas exist in dev and test only and are never deployed further.
