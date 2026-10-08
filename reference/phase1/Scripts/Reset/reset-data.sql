/*====================================================================
    Layercake - DATA RESET

    Empties every table in the Layercake schema and rewinds every
    identity, leaving the objects in place. The pipeline is then in the
    same state as a freshly deployed blank database, so the next

        exec Layercake.usp_run_daily_load;

    is a full historical backfill again.

    *** THIS DELETES ALL PIPELINE DATA. TEST DATABASES ONLY. ***

    Use this rather than the teardown when the SHAPE has not changed and
    you only want to re-run the load from zero. It clears, among others:

      * the bronze snapshots, so the next bronze load inserts rather
        than diff-syncs;
      * Layercake.etl_daily_count_loaded, the per-date checkpoint -
        without this the silver daily-count walk would skip every date
        it has already marked;
      * etl_run_log / etl_progress_log / etl_daily_count_pending_rebuild,
        so the run history starts clean;
      * the recon_* diagnostic tables.

    ONE TABLE IS EXEMPT: Layercake.schema_migration. It records which
    migrations this database has had applied, which is a fact about the
    SHAPE of the objects, not about the data in them. This reset leaves
    the objects exactly as they are, so the journal must survive - clear
    it and the next deploy would try to re-apply every migration against
    tables that already have the change. Use -Reset Objects / -Fresh when
    you want the journal gone too; that rebuilds and re-baselines it.

    SEED ROWS GO TOO. Re-run 03_SeedData afterwards or the id-0 'N/A'
    members are missing and the gold loads will fail to resolve keys:

        Deploy-Database.ps1 -Phase 03

    (-Reset Data does this for you.)

    ref_enrolment_exception is cleared here as well, and phase 03 does NOT
    bring it back - since 20260928_02 the capture lives in the silver load
    (Layercake.usp_load_ref_enrolment_exception). The next
    usp_run_daily_load re-captures the whole cohort from bronze under the
    current rules, which is also the first full backfill, so the counts it
    produces already include them.

    Order does not matter: every foreign key is disabled first, then
    re-enabled WITH CHECK at the end so it stays TRUSTED. Tables that
    nothing references are TRUNCATEd; the rest - the dimensions and
    reference tables that facts point at - are DELETEd and their
    identity rewound to the original seed, because TRUNCATE is not
    allowed on an FK target even with the constraint disabled.

    Knob at the top of the file:
        @whatif   1 = print what would happen and change nothing.

    Usage:
        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i reset-data.sql -b -N -I
        .\Deploy-Database.ps1 -Reset Data        -- this, then 03_SeedData
====================================================================*/

set nocount on;
set xact_abort on;

declare @whatif bit = 0;          -- <<< 1 = dry run

declare @schema sysname = N'Layercake';

if schema_id(@schema) is null
begin
    print concat('Schema ', @schema, ' does not exist - deploy the project first.');
    return;
end

/*--------------------------------------------------------------------
    One row per table: how to clear it, and whether an identity needs
    rewinding afterwards. Row counts come from partition stats rather
    than count(*) so the plan is instant on the big fact tables.
--------------------------------------------------------------------*/
declare @tables table
(
    seq          int identity(1, 1) not null primary key,
    full_name    nvarchar(300) not null,
    can_truncate bit not null,
    reseed_to    bigint null,
    rows_before  bigint not null
);

insert into @tables (full_name, can_truncate, reseed_to, rows_before)
select concat(quotename(@schema), '.', quotename(t.name)),
       case when exists (select 1 from sys.foreign_keys fk where fk.referenced_object_id = t.object_id)
            then 0 else 1 end,
       -- seed_value / increment_value are sql_variant, so convert before the subtract
       (select top 1 convert(bigint, ic.seed_value) - convert(bigint, ic.increment_value)
        from sys.identity_columns ic where ic.object_id = t.object_id),
       isnull((select sum(ps.row_count)
               from sys.dm_db_partition_stats ps
               where ps.object_id = t.object_id and ps.index_id in (0, 1)), 0)
from sys.tables t
where t.schema_id = schema_id(@schema)
  and t.name <> N'schema_migration'   -- deploy journal: shape, not data. See header.
order by t.name;

declare @total int, @rows bigint;
select @total = count(*), @rows = sum(rows_before) from @tables;

print concat('Data reset of schema ', @schema, ': ', @total, ' table(s), ~',
             format(@rows, 'N0'), ' row(s)',
             case when @whatif = 1 then '   *** WHAT-IF - nothing will be changed ***' else '' end);
print replicate('-', 70);

/*------------------------------------------- 1. disable every FK --*/
declare @seq int = 0, @next int, @sql nvarchar(max),
        @name nvarchar(300),
        @trunc bit, @reseed bigint, @before bigint,
        @cleared int = 0;

while 1 = 1
begin
    select top 1 @next = seq, @name = full_name from @tables where seq > @seq order by seq;
    if @@rowcount = 0 break;
    set @seq = @next;

    set @sql = concat('alter table ', @name, ' nocheck constraint all;');
    if @whatif = 0 exec sys.sp_executesql @sql;
end

/*---------------------------------------------- 2. clear + rewind --*/
set @seq = 0;
while 1 = 1
begin
    select top 1 @next = seq, @name = full_name,
                 @trunc = can_truncate, @reseed = reseed_to, @before = rows_before
    from @tables where seq > @seq order by seq;
    if @@rowcount = 0 break;
    set @seq = @next;

    if @trunc = 1
        set @sql = concat('truncate table ', @name, ';');
    else
        set @sql = concat('delete from ', @name, ';');

    -- TRUNCATE rewinds the identity itself; DELETE does not
    if @trunc = 0 and @reseed is not null
        set @sql = concat(@sql, char(13), char(10),
                          'dbcc checkident (''', @name, ''', reseed, ', @reseed, ') with no_infomsgs;');

    print concat('  ', case when @trunc = 1 then 'truncate ' else 'delete   ' end,
                 @name, '  (', format(@before, 'N0'), ' rows)');

    if @whatif = 0
    begin
        begin try
            exec sys.sp_executesql @sql;
            set @cleared += 1;
        end try
        begin catch
            print concat('  *** FAILED on ', @name, ': ', error_message());
            throw;
        end catch
    end
end

/*--------------------------- 3. re-enable every FK, still TRUSTED --*/
set @seq = 0;
while 1 = 1
begin
    select top 1 @next = seq, @name = full_name from @tables where seq > @seq order by seq;
    if @@rowcount = 0 break;
    set @seq = @next;

    -- WITH CHECK on now-empty tables validates instantly and keeps is_not_trusted = 0
    set @sql = concat('alter table ', @name, ' with check check constraint all;');
    if @whatif = 0 exec sys.sp_executesql @sql;
end

print replicate('-', 70);
if @whatif = 1
    print concat('What-if only. ', @total, ' table(s) would have been cleared.');
else
begin
    print concat('Data reset complete: ', @cleared, ' table(s) cleared.');
    print 'NEXT: Deploy-Database.ps1 -Phase 03   (reload the seed rows)';
    print '      exec Layercake.usp_run_daily_load;   -- full historical backfill';
end
go
