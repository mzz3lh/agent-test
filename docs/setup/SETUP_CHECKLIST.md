# Setup checklist and access request: RICS Phase 2 (RICS)

The Product Owner prepared everything below. **A human reviews and runs each step.** No agent has run any of it.
One-time machine setup (Python, local SQL Server, CLR, tSQLt download) is in the agent team framework's README and is not repeated here.

## Access request

| | |
|---|---|
| Requested by | Product Owner agent |
| Request | Create agent roles and users in `RICS_Dev` and `RICS_Test` as listed in `ACCESS_MATRIX.md` |
| Production access requested | None |
| Grant-capable rights requested | None (checked by `po_setup.py`) |
| Approved by | _name, date_ |

## Steps

- [ ] 1. Review `config/project.yaml` and `docs/setup/ACCESS_MATRIX.md`. If anything is wrong, edit the YAML and regenerate from the framework: `python agents/product_owner/po_setup.py render-access --project <this repo>`.
- [ ] 2. Run `src/sql/setup/00_create_databases.sql` as admin.
- [ ] 3. Install tSQLt into `RICS_Dev` and `RICS_Test` (framework: `local-sql/10_install_tsqlt.md`).
- [ ] 4. Run `src/sql/setup/01_create_roles.sql` in `RICS_Dev`, then in `RICS_Test`.
- [ ] 5. Generate one password per agent in your secret store. Run `src/sql/setup/02_create_agent_users.sql` in SQLCMD mode in each database (instructions in the file header). Passwords must not contain a single quote.
- [ ] 6. Run `src/sql/setup/03_grant_access_dev.sql` and `04_grant_access_test.sql`.
- [ ] 7. Run `src/sql/setup/05_verify_access.sql` in each database. The last result set must be empty. Save the output with this checklist.
- [ ] 8. Run `src/sql/deploy/MIG-0000_bootstrap_migration-history.up.sql` in SQLCMD mode (`-v CommitHash=<git sha>`) in both databases, then `src/sql/deploy/MIG-0001_bootstrap_audit-tables.up.sql` (load audit tables) the same way. `SELECT * FROM etl.vw_DatabaseVersion;` returns `MIG-0001`.
- [ ] 9. Run `tests/tsqlt/test_Smoke.sql` and `EXEC tSQLt.Run 'test_Smoke';` in each database. Both tests pass.
- [ ] 10. Sign the access request above.
- [ ] 11. Turn on the project CI (`.github/workflows/project-ci.yml`): in the project repository's Settings > Secrets and variables > Actions, add the variable `FRAMEWORK_REPO` (the framework repository, owner/name), optionally `FRAMEWORK_REF` (default `main`), and the secret `FRAMEWORK_TOKEN` (a fine-grained token with read-only Contents access to the framework repository). The first push runs it; both jobs' steps go green on the new project.

To withdraw all agent access at any point: `src/sql/setup/99_revoke_agent_access.sql`.
