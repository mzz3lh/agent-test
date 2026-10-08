<#
.SYNOPSIS
    Deploys the Layercake database project to a SQL Server / Azure SQL target.

.DESCRIPTION
    Walks the numbered phase folders in order and executes every .sql file in
    each via sqlcmd:

        01_Security        schema
        02_Tables          all tables, their keys and intrinsic indexes
        03_SeedData        static reference rows (id-0 'N/A' members etc.)
        04_Programmability stored procedures
        05_Indexes         performance indexes
        06_Constraints     foreign keys
        07_Migrations      in-place ALTERs for databases that already exist

    Within a phase, files run in alphabetical order. That is safe by design:
    no table script references another table (foreign keys are phase 06), and
    procedures resolve their dependencies at run time, not create time.

    EVERY PHASE EXCEPT 02 IS RE-RUNNABLE. Anything that can be rebuilt
    without losing data rebuilds itself: phase 01 creates the schema only if
    it is missing, phase 03 (seed DML) guards every insert, phase 04 is
    CREATE OR ALTER throughout, and phases 05/06 drop each index and foreign
    key if present before recreating it - so what is in the database is
    always what is in these files.

    PHASE 02 (TABLES) IS THE EXCEPTION. Table scripts are fresh CREATEs and
    will FAIL on a database that already has them. That is deliberate: a
    table holds data, so recreating it is never automatic. Use -SkipTables
    to redeploy everything else over a live database, or -Fresh to tear the
    schema down and rebuild it from nothing.

    PHASE 07 (MIGRATIONS) IS HOW A TABLE CHANGES SHAPE IN PLACE. Because
    phase 02 cannot alter a table that already exists, every change to a
    table's shape is written twice: the 02 file is edited so new databases
    get the new shape, and a migration is added under 07_Migrations so
    existing databases get it too. See 07_Migrations/README.md and the
    rules in CLAUDE.md at the repo root.

    Phase 07 runs last and is journalled in Layercake.schema_migration, so
    each migration is accounted for exactly once per database. The runner
    picks one of two modes automatically:

      APPLY     phase 02 did not run, so the database already existed and
                its tables are at their old shape. Migrations not already
                in the journal are EXECUTED, in file order, and recorded
                as 'run'.

      BASELINE  phase 02 ran in this same invocation, so the tables were
                just built from the current 02 definitions and already
                have the new shape. Migrations are RECORDED as 'baseline'
                WITHOUT being executed - running them would fail on
                objects that are already final.

    Baseline is what keeps -Fresh working as the migration folder grows.

    Connection details come from parameters, or fall back to environment
    variables:
        RICS_SQL_SERVER     e.g. myserver.database.windows.net
        RICS_SQL_DATABASE   e.g. LayercakeRICS
        RICS_SQL_USER
        RICS_SQL_PASSWORD

    If no password is available it is prompted for securely (never echoed).

.PARAMETER Phase
    Run only these phases. Accepts two-digit prefixes and/or name fragments,
    comma-separated.
        -Phase 04                    # redeploy every stored procedure
        -Phase Programmability       # same thing
        -Phase 05,06                 # indexes + foreign keys only

.PARAMETER Filter
    Run only files whose path matches one of these fragments (applied after
    -Phase). Case-insensitive.
        -Phase 04 -Filter silv_      # just the silver load modules
        -Filter brnz_contact         # one table + its module

.PARAMETER SkipTables
    Leave phase 02 out of the run. Every other phase is re-runnable, so this
    is the safe way to redeploy over a live database: the schema, seed rows,
    procedures, indexes and foreign keys are all brought back into line with
    the files, and the tables (with their data) are left alone.

        -SkipTables                  # redeploy everything but the tables

.PARAMETER SkipMigrations
    Leave phase 07 out of the run entirely - no migrations applied, no
    journal rows written, the journal table not even looked at. Use it to
    deploy code (procedures, indexes) without touching table shape.

        -SkipTables -SkipMigrations   # procedures/indexes/FKs only

.PARAMETER List
    Show what WOULD run (after filtering) and exit without executing.

.PARAMETER ContinueOnError
    Keep going if a file fails (default is stop on the first failure).

.PARAMETER Reset
    Clear the target down before doing anything else. TEST DATABASES
    ONLY - both options destroy data, and you are asked to confirm by
    typing the database name unless -Force is given.

        -Reset Data      Empty every Layercake table and rewind every
                         identity, leaving the objects in place, then
                         reload phase 03 seed data. The pipeline is back
                         to a blank-database state and the next
                         usp_run_daily_load is a full backfill.
                         (Scripts/Reset/reset-data.sql)

        -Reset Objects   Drop every object in the Layercake schema and
                         the schema itself.
                         (Scripts/Reset/teardown-all.sql)

    On its own, -Reset does the reset and stops. Combine it with -Fresh,
    or with -Phase / -Filter, to deploy afterwards.

.PARAMETER Fresh
    The full testing round trip: -Reset Objects followed by a complete
    deploy of every phase. Equivalent to dropping the schema and running
    this script against a blank database.

.PARAMETER Force
    Skip the confirmation prompt on -Reset / -Fresh. For unattended runs.

.EXAMPLE
    .\Deploy-Database.ps1
    Full deploy to a blank database.

.EXAMPLE
    .\Deploy-Database.ps1 -Phase 04
    Redeploy all 45 stored procedures over an existing database.

.EXAMPLE
    .\Deploy-Database.ps1 -SkipTables
    Redeploy everything except the tables over an existing database. Nothing
    fails on objects that are already there, and no data is touched.

.EXAMPLE
    .\Deploy-Database.ps1 -List
    Preview the full ordered file list without connecting.

.EXAMPLE
    .\Deploy-Database.ps1 -Fresh
    Wipe the schema completely and redeploy it from scratch.

.EXAMPLE
    .\Deploy-Database.ps1 -Reset Data
    Keep the objects, throw away every row, reload the seed rows.

.EXAMPLE
    .\Deploy-Database.ps1 -Reset Objects -List
    Show the teardown and deploy plan without touching the database.

.EXAMPLE
    .\Deploy-Database.ps1 -SkipTables
    The routine rollout over a live database: every re-runnable phase is
    brought back into line with the files, then any migration this database
    has not seen yet is applied and journalled.

.EXAMPLE
    .\Deploy-Database.ps1 -Phase 07
    Apply pending migrations and nothing else.

.EXAMPLE
    .\Deploy-Database.ps1 -SkipTables -SkipMigrations
    Redeploy code only. Table shape is left exactly as it is.
#>
[CmdletBinding()]
param(
    [string]   $Server    = $env:RICS_SQL_SERVER,
    [string]   $Database  = $env:RICS_SQL_DATABASE,
    [string]   $User      = $env:RICS_SQL_USER,
    [string]   $Password  = $env:RICS_SQL_PASSWORD,   # prefer env var; prompted if absent
    [string]   $ProjectRoot = $PSScriptRoot,
    [string[]] $Phase,
    [string[]] $Filter,
    [switch]   $SkipTables,
    [switch]   $SkipMigrations,
    [switch]   $List,
    [switch]   $ContinueOnError,
    [ValidateSet('Data', 'Objects')]
    [string]   $Reset,
    [switch]   $Fresh,
    [switch]   $Force
)

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------------- intent --
# -Fresh is -Reset Objects plus a deploy. A bare -Reset resets and stops;
# add -Phase / -Filter (or -Fresh) to deploy afterwards.
if ($Fresh -and -not $Reset) { $Reset = 'Objects' }
$deploy = $Fresh -or (-not $Reset) -or $Phase -or $Filter

# -SkipTables exists to protect tables that already hold data. After an
# object teardown there are none, and skipping phase 02 would leave every
# later phase with nothing to bind to.
if ($SkipTables -and $Reset -eq 'Objects') {
    Write-Error '-SkipTables cannot be combined with -Fresh / -Reset Objects: the teardown drops the tables, so phase 02 has to run.'
}

# ---------------------------------------------------------------- discovery --
if (-not $ProjectRoot) { $ProjectRoot = Get-Location }

$phaseDirs = Get-ChildItem -Path $ProjectRoot -Directory |
    Where-Object { $_.Name -match '^\d{2}_' } |
    Sort-Object Name

if (-not $phaseDirs) {
    Write-Error "No NN_* phase folders found in '$ProjectRoot'. Is this the project root?"
}

$allPhaseDirs = $phaseDirs

if ($Phase) {
    $phaseDirs = $phaseDirs | Where-Object {
        $dir = $_
        $matched = $false
        foreach ($p in $Phase) {
            $p = $p.Trim()
            if ($p -match '^\d{1,2}$') {
                if ($dir.Name.Substring(0, 2) -eq $p.PadLeft(2, '0')) { $matched = $true }
            }
            elseif ($dir.Name -like "*$p*") { $matched = $true }
        }
        $matched
    }
}

# 07_Migrations is a phase folder by name but is not deployed like one: its
# files are journalled and applied at most once per database, after every other
# phase. Split it out of the ordinary walk.
$migrationDir = $phaseDirs | Where-Object { $_.Name -like '07_*' } | Select-Object -First 1
$phaseDirs    = $phaseDirs | Where-Object { $_.Name -notlike '07_*' }
if ($SkipMigrations) { $migrationDir = $null }

# 02 is the only phase that is not re-runnable - table scripts are fresh
# CREATEs because a table holds data. Dropping it from the run is what makes
# a redeploy over a live database safe.
if ($SkipTables) {
    $phaseDirs = $phaseDirs | Where-Object { $_.Name -notlike '02_*' }
}

# Phase 02 running means the tables are being built from the current
# definitions, which already contain every migrated change - so migrations get
# journalled without being executed. A -Filter run is not a build of anything,
# whatever it happens to match, so it never counts as one.
$tablesInRun = [bool]($phaseDirs | Where-Object { $_.Name -like '02_*' }) -and -not $Filter

if ($deploy -and -not $phaseDirs -and -not $migrationDir) {
    Write-Warning 'No phases match the requested subset. Nothing to do.'
    return
}

# ordered file list: phases in order, files alphabetical within each phase
$files = @()
if ($deploy) {
    foreach ($dir in $phaseDirs) {
        $inPhase = Get-ChildItem -Path $dir.FullName -Filter '*.sql' -File -Recurse |
            Sort-Object FullName
        if ($Filter) {
            $inPhase = $inPhase | Where-Object {
                $f = $_
                $hit = $false
                foreach ($frag in $Filter) { if ($f.FullName -like "*$($frag.Trim())*") { $hit = $true } }
                $hit
            }
        }
        $files += $inPhase
    }

}

# Migrations are deliberately NOT recursed: the file name is the identity
# recorded in the journal, so the id space stays flat and unambiguous.
$migrationFiles = @()
if ($deploy -and $migrationDir) {
    $migrationFiles = Get-ChildItem -Path $migrationDir.FullName -Filter '*.sql' -File |
        Sort-Object Name
    if ($Filter) {
        $migrationFiles = $migrationFiles | Where-Object {
            $f = $_
            $hit = $false
            foreach ($frag in $Filter) { if ($f.FullName -like "*$($frag.Trim())*") { $hit = $true } }
            $hit
        }
    }
}

if ($deploy -and -not $files -and -not $migrationFiles) {
    Write-Warning 'No files match the requested subset. Nothing to do.'
    return
}

# ------------------------------------------------------------------- reset --
# The reset scripts live under Scripts/ so a normal deploy never picks them up;
# they only run when asked for by name here.
$resetFiles = @()
if ($Reset) {
    $resetScript = switch ($Reset) {
        'Data'    { 'reset-data.sql' }
        'Objects' { 'teardown-all.sql' }
    }
    $resetPath = Join-Path $ProjectRoot "Scripts/Reset/$resetScript"
    if (-not (Test-Path -LiteralPath $resetPath)) {
        Write-Error "Reset script not found: $resetPath"
    }
    $resetFiles += Get-Item -LiteralPath $resetPath

    # A data reset empties the seed tables too, so phase 03 has to follow it.
    # Drop phase 03 from the deploy list if it is also selected there: every
    # seed insert is guarded so a second pass would not fail, it would just
    # be a wasted round trip.
    if ($Reset -eq 'Data') {
        $seedDir = $allPhaseDirs | Where-Object { $_.Name -like '03_*' }
        if ($seedDir) {
            $resetFiles += Get-ChildItem -Path $seedDir.FullName -Filter '*.sql' -File -Recurse |
                Sort-Object FullName
            $files = @($files | Where-Object { $_.FullName -notlike "$($seedDir.FullName)*" })
        }
    }
}

# --------------------------------------------------------------------- plan --
function Get-RelPath($file) { $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/') }

Write-Host "`nProject: $ProjectRoot" -ForegroundColor Cyan

if ($resetFiles) {
    $what = if ($Reset -eq 'Objects') { 'DROP every object in the Layercake schema, and the schema itself' }
            else                      { 'DELETE every row in every Layercake table, then reload the seed rows' }
    Write-Host "Reset ($Reset): $what" -ForegroundColor Yellow
    foreach ($f in $resetFiles) { Write-Host "      $(Get-RelPath $f)" -ForegroundColor Yellow }
}

if ($files) {
    Write-Host "Files selected ($($files.Count)):" -ForegroundColor Cyan
    $lastPhase = ''
    foreach ($f in $files) {
        $rel = Get-RelPath $f
        $thisPhase = ($rel -split '[\\/]')[0]
        if ($thisPhase -ne $lastPhase) {
            Write-Host "  $thisPhase" -ForegroundColor DarkCyan
            $lastPhase = $thisPhase
        }
        Write-Host "      $(Split-Path $rel -Leaf)"
    }
}

if ($migrationFiles) {
    # APPLY vs BASELINE is known now, but which files are still PENDING is not -
    # that is a property of the target database, read from the journal at run
    # time. -List never connects, so it cannot say.
    $mode = if ($tablesInRun) { 'BASELINE - recorded, NOT executed (tables built fresh this run)' }
            else              { 'APPLY - executed if not already in the journal' }
    Write-Host "Migrations ($($migrationFiles.Count)): $mode" -ForegroundColor DarkCyan
    foreach ($m in $migrationFiles) { Write-Host "      $($m.Name)" }
}

if ($List) { Write-Host "`n-List specified; not executing." -ForegroundColor Yellow; return }

# --------------------------------------------------------------- connection --
if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error 'sqlcmd not found on PATH. Install it (winget install sqlcmd) and retry.'
}
if (-not $Server)   { $Server   = Read-Host 'SQL server (e.g. myserver.database.windows.net)' }
if (-not $Database) { $Database = Read-Host 'Database name' }
if (-not $User)     { $User     = Read-Host 'SQL login' }
if (-not $Password) {
    $sec = Read-Host "Password for '$User'" -AsSecureString
    $Password = [System.Net.NetworkCredential]::new('', $sec).Password
}

Write-Host "`nTarget: $Server / $Database as $User`n" -ForegroundColor Cyan

# ------------------------------------------------------------ confirmation --
# A reset is not recoverable, so make the operator name the target. -Force skips
# it for unattended runs.
if ($resetFiles -and -not $Force) {
    Write-Host 'THIS DESTROYS DATA. TEST DATABASES ONLY.' -ForegroundColor Red
    Write-Host "  $Server / $Database" -ForegroundColor Red
    $typed = Read-Host "Type the database name to confirm (anything else aborts)"
    if ($typed -ne $Database) {
        Write-Host 'Aborted. Nothing was changed.' -ForegroundColor Yellow
        return
    }
    Write-Host ''
}

# ---------------------------------------------------------------- execution --
$failed = @()
$all = [System.Diagnostics.Stopwatch]::StartNew()
$lastPhase = ''
$ran = 0

# -b : exit with error code on SQL error   -N : encrypt (required by Azure SQL)
# -I : QUOTED_IDENTIFIER ON (needed for filtered indexes)
function Invoke-SqlFile($file) {
    & sqlcmd -S $Server -d $Database -U $User -P $Password `
             -i $file.FullName -b -N -I -l 30
    return $LASTEXITCODE
}

# -h -1 : no header rows   -W : strip padding, so a row comes back as its value
function Invoke-SqlQuery($query) {
    $out = & sqlcmd -S $Server -d $Database -U $User -P $Password `
                    -Q $query -b -N -I -l 30 -h -1 -W
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Query failed on $Database (exit $LASTEXITCODE): $query"
    }
    return @($out | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
}

function Invoke-SqlNonQuery($query) {
    & sqlcmd -S $Server -d $Database -U $User -P $Password `
             -Q $query -b -N -I -l 30 | Out-Null
    return $LASTEXITCODE
}

foreach ($f in @($resetFiles) + @($files)) {
    $rel = Get-RelPath $f
    $thisPhase = ($rel -split '[\\/]')[0]
    if ($thisPhase -ne $lastPhase) {
        Write-Host ('-' * 70)
        if ($thisPhase -eq 'Scripts') { Write-Host "RESET $Reset" -ForegroundColor Yellow }
        else                          { Write-Host "PHASE $thisPhase" -ForegroundColor Cyan }
        $lastPhase = $thisPhase
    }

    $ran++
    $exit = Invoke-SqlFile $f

    if ($exit -ne 0) {
        Write-Host "  FAILED: $rel (exit $exit)" -ForegroundColor Red
        $failed += $rel
        if (-not $ContinueOnError) {
            Write-Error "Stopping: $rel failed. Use -ContinueOnError to keep going."
        }
    }
    else {
        Write-Host "  ok  $(Split-Path $rel -Leaf)" -ForegroundColor Green
    }
}

# --------------------------------------------------------------- migrations --
# Journalled, and applied at most once per database. See the script header for
# the APPLY / BASELINE distinction.
if ($migrationFiles) {
    Write-Host ('-' * 70)
    Write-Host "PHASE $($migrationDir.Name)" -ForegroundColor Cyan

    if ($failed) {
        Write-Warning 'Earlier files failed (-ContinueOnError). Migrations will still be attempted.'
    }

    # The journal is an ordinary phase 02 table, so a full deploy has just
    # created it. On a -SkipTables run over a database that predates the
    # journal it is missing - create it from that same file, so there is only
    # ever one definition of it anywhere.
    $journalFile = Join-Path $ProjectRoot '02_Tables/Control/Layercake.schema_migration.sql'
    $journalHere = Invoke-SqlQuery @"
set nocount on;
select count(*) from sys.tables t
join sys.schemas s on s.schema_id = t.schema_id
where s.name = 'Layercake' and t.name = 'schema_migration';
"@

    if (@($journalHere)[0] -eq '0') {
        if (-not (Test-Path -LiteralPath $journalFile)) {
            Write-Error "Migration journal definition not found: $journalFile"
        }
        Write-Host '  creating Layercake.schema_migration (migration journal)' -ForegroundColor Yellow
        if ((Invoke-SqlFile (Get-Item -LiteralPath $journalFile)) -ne 0) {
            Write-Error 'Could not create the migration journal. Stopping before any migration runs.'
        }
        if (-not $tablesInRun) {
            # First journal on a database that already existed. Everything here
            # is about to be treated as pending, including changes a previous
            # operator may already have made by hand.
            Write-Warning 'This database had no migration journal. Every migration below is treated as pending - check the list if any were applied by hand before now.'
        }
    }

    $alreadyApplied = Invoke-SqlQuery 'set nocount on; select migration_id from Layercake.schema_migration;'
    $migrationMode  = if ($tablesInRun) { 'baseline' } else { 'run' }
    $deployHost     = "$env:COMPUTERNAME".Replace("'", "''")

    if ($migrationMode -eq 'baseline') {
        Write-Host '  BASELINE: tables were built from the current definitions this run, so migrations are recorded without being executed.' -ForegroundColor DarkCyan
    }

    foreach ($m in $migrationFiles) {
        $id = [System.IO.Path]::GetFileNameWithoutExtension($m.Name)

        if ($alreadyApplied -contains $id) {
            Write-Host "  --  $id  (already applied)" -ForegroundColor DarkGray
            continue
        }

        $ran++
        $idSql = $id.Replace("'", "''")
        $ms    = 'null'

        if ($migrationMode -eq 'run') {
            $sw   = [System.Diagnostics.Stopwatch]::StartNew()
            $exit = Invoke-SqlFile $m
            $sw.Stop()

            if ($exit -ne 0) {
                Write-Host "  FAILED: $($m.Name) (exit $exit) - NOT journalled, so it stays pending" -ForegroundColor Red
                $failed += "07_Migrations/$($m.Name)"
                if (-not $ContinueOnError) {
                    Write-Error "Stopping: migration $id failed. Use -ContinueOnError to keep going."
                }
                continue
            }
            $ms = [int]$sw.Elapsed.TotalMilliseconds
        }

        $journalExit = Invoke-SqlNonQuery @"
insert into Layercake.schema_migration (migration_id, applied_by, duration_ms, deployed_from)
values (N'$idSql', N'$migrationMode', $ms, N'$deployHost');
"@

        if ($journalExit -ne 0) {
            if ($migrationMode -eq 'run') {
                # The worst case: the change is in the database but nothing
                # records it, so the next deploy would try to apply it again.
                Write-Host "  *** $id RAN but could NOT be journalled. Insert it into Layercake.schema_migration by hand before the next deploy." -ForegroundColor Red
            }
            else {
                Write-Host "  FAILED to journal $id (exit $journalExit)" -ForegroundColor Red
            }
            $failed += "07_Migrations/$($m.Name) (journal)"
            if (-not $ContinueOnError) {
                Write-Error "Stopping: could not journal $id. Use -ContinueOnError to keep going."
            }
            continue
        }

        if ($migrationMode -eq 'run') {
            Write-Host "  ok  $($m.Name)  ($ms ms)" -ForegroundColor Green
        }
        else {
            Write-Host "  rec $($m.Name)  (baseline - not executed)" -ForegroundColor DarkCyan
        }
    }
}

# ------------------------------------------------------------------ summary --
$all.Stop()
Write-Host ('-' * 70)
if ($failed) {
    Write-Host "Done with FAILURES in $($all.Elapsed.ToString('mm\:ss')) ($($failed.Count) of $ran):" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
Write-Host "All $ran file(s) ran successfully in $($all.Elapsed.ToString('mm\:ss'))." -ForegroundColor Green

if ($Reset -eq 'Objects' -and -not $files) {
    Write-Host "`nSchema dropped. Next: .\Deploy-Database.ps1   -- redeploy from scratch" -ForegroundColor Cyan
}
else {
    Write-Host "`nNext: exec Layercake.usp_run_daily_load;   -- first run is the full historical backfill" -ForegroundColor Cyan
}
