# RICS Phase 2 (RICS)

Data project delivered with the agent team framework (base standards v1.6). Created 2026-10-08 by the Product Owner's `new-project` command.

- `PROJECT_STANDARDS.md`: project facts and approved overrides on top of the base standards
- `config/project.yaml`: environments and agent access (source of truth)
- `docs/setup/`: environments, generated access matrix, setup checklist
- `docs/requirements/` → `docs/specs/` → `docs/design/` (+ `adr/`) → `docs/test/` → `docs/handover/`
- `src/sql/setup/`: human-run database and access scripts
- `src/sql/deploy/`: migrations (`MIG-nnnn` up/down pairs; templates in `templates/`)
- `src/sql/ci/`: CI-only stand-ins for objects another system owns (see its README)
- `tests/tsqlt/`, `tests/pytest/`
- `.github/workflows/project-ci.yml`: CI on every push and pull request (artefacts, migration checks, and a clean SQL Server 2022 build with every tSQLt suite)

Start with `docs/setup/SETUP_CHECKLIST.md`.
