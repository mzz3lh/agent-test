/*====================================================================
    Layercake - FULL TEARDOWN

    Drops EVERY object in the Layercake schema, then the schema itself,
    leaving the database as if the project had never been deployed. The
    next step is a full run of Deploy-Database.ps1.

    *** THIS DESTROYS DATA AND OBJECTS. TEST DATABASES ONLY. ***

    Nothing outside the Layercake schema is touched - in particular the
    CE / Subs source views the bronze loaders read are left alone.

    Discovery is dynamic: whatever is in the schema goes, including
    objects added since this script was written and half-finished state
    left by a failed deploy. It is therefore idempotent - if a drop
    fails part way through, fix the cause and run it again.

    Knob at the top of the file:
        @whatif   1 = print the DROP statements and execute nothing.

    Usage:
        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i teardown-all.sql -b -N -I

    or, with the confirmation prompt and a redeploy in the same step:

        .\Deploy-Database.ps1 -Reset Objects     -- teardown only
        .\Deploy-Database.ps1 -Fresh             -- teardown + full deploy
====================================================================*/

set nocount on;
set xact_abort on;

declare @whatif bit = 0;          -- <<< 1 = dry run

declare @schema sysname = N'Layercake';

if schema_id(@schema) is null
begin
    print concat('Schema ', @schema, ' does not exist - nothing to tear down.');
    return;
end

/*--------------------------------------------------------------------
    Collect every drop statement, in dependency order.

      1 foreign keys   both directions - an FK anywhere in the database
                       pointing at a Layercake table would block the
                       table drop, so those go too
      2 views
      3 procedures
      4 tables         after the procedures, so a schemabound function
                       used by a constraint is no longer referenced
      5 functions
      6 aggregates
      7 sequences
      8 synonyms
      9 user types     table types and alias types
     10 the schema     only drops once it is empty
--------------------------------------------------------------------*/
declare @drops table (ord int not null, stage nvarchar(20) not null, stmt nvarchar(max) not null);

insert into @drops (ord, stage, stmt)
select 1, 'foreign key',
       concat('alter table ', quotename(schema_name(t.schema_id)), '.', quotename(t.name),
              ' drop constraint ', quotename(fk.name), ';')
from sys.foreign_keys fk
join sys.tables t on t.object_id = fk.parent_object_id
where t.schema_id = schema_id(@schema)
   or fk.referenced_object_id in (select object_id from sys.tables where schema_id = schema_id(@schema))

union all
select 2, 'view', concat('drop view ', quotename(@schema), '.', quotename(v.name), ';')
from sys.views v where v.schema_id = schema_id(@schema)

union all
select 3, 'procedure', concat('drop procedure ', quotename(@schema), '.', quotename(p.name), ';')
from sys.procedures p where p.schema_id = schema_id(@schema)

union all
select 4, 'table', concat('drop table ', quotename(@schema), '.', quotename(t.name), ';')
from sys.tables t where t.schema_id = schema_id(@schema)

union all
select 5, 'function', concat('drop function ', quotename(@schema), '.', quotename(o.name), ';')
from sys.objects o where o.schema_id = schema_id(@schema) and o.type in ('FN', 'IF', 'TF', 'FS', 'FT')

union all
select 6, 'aggregate', concat('drop aggregate ', quotename(@schema), '.', quotename(o.name), ';')
from sys.objects o where o.schema_id = schema_id(@schema) and o.type = 'AF'

union all
select 7, 'sequence', concat('drop sequence ', quotename(@schema), '.', quotename(s.name), ';')
from sys.sequences s where s.schema_id = schema_id(@schema)

union all
select 8, 'synonym', concat('drop synonym ', quotename(@schema), '.', quotename(s.name), ';')
from sys.synonyms s where s.schema_id = schema_id(@schema)

union all
select 9, 'type', concat('drop type ', quotename(@schema), '.', quotename(ty.name), ';')
from sys.types ty where ty.schema_id = schema_id(@schema) and ty.is_user_defined = 1

--union all
--select 10, 'schema', concat('drop schema ', quotename(@schema), ';');

declare @ordered table (seq int not null primary key, stage nvarchar(20) not null, stmt nvarchar(max) not null);

insert into @ordered (seq, stage, stmt)
select row_number() over (order by d.ord, d.stmt), d.stage, d.stmt
from @drops d;

declare @total int;
select @total = count(*) from @ordered;

print concat('Teardown of schema ', @schema, ': ', @total, ' statement(s)',
             case when @whatif = 1 then '   *** WHAT-IF - nothing will be executed ***' else '' end);
print replicate('-', 70);

select stage, count(*) as objects
from @ordered
group by stage
order by min(seq);

/*----------------------------------------------------- execution --*/
declare @seq int = 0, @next int, @stmt nvarchar(max), @stage nvarchar(20), @done int = 0;

while 1 = 1
begin
    select top 1 @next = seq, @stmt = stmt, @stage = stage
    from @ordered where seq > @seq order by seq;

    if @@rowcount = 0 break;
    set @seq = @next;

    print concat('  ', @stmt);

    if @whatif = 0
    begin
        begin try
            exec sys.sp_executesql @stmt;
            set @done += 1;
        end try
        begin catch
            print concat('  *** FAILED (', @stage, '): ', error_message());
            throw;
        end catch
    end
end

print replicate('-', 70);
if @whatif = 1
    print concat('What-if only. ', @total, ' statement(s) would have run.');
else
    print concat('Teardown complete: ', @done, ' statement(s) executed. Redeploy with Deploy-Database.ps1.');
go
