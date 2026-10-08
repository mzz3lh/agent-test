# Phase 1 solution (reference only)

The existing Layercake RICS database project as supplied by Mike on 2026-10-08, unchanged except:

- `Scripts/Debugging/` was left out: its ad hoc queries name real contact numbers (personal identifiers),
  which base standards section 7 keeps out of the repository.

This folder is read-only input for the agents (the Phase 1 objects Phase 2 builds on). It is not deployed
by the framework; the Phase 1 baseline is deployed to RICS_Dev and RICS_Test with its own
`Deploy-Database.ps1`.
