/*====================================================================
    Layercake.schema_migration
    Control layer - table, keys and intrinsic indexes

    The deploy journal. One row per migration file under 07_Migrations
    that has been accounted for on THIS database, so the runner can
    apply only what is pending and never apply the same change twice.

    migration_id is the file name without the extension - it is the
    identity of the migration, which is why migration files are never
    renamed once they have been deployed anywhere.

    applied_by distinguishes the two ways a row gets here:

      'run'       the file was executed against this database, because
                  the database already existed and the change had to be
                  made in place.

      'baseline'  the file was NOT executed, only recorded. The schema
                  was built from scratch in the same deploy, so the
                  02_Tables definitions already contain the change and
                  running the migration would fail on an object that is
                  already in its final shape.

    Deploy-Database.ps1 decides between the two; see its header.
====================================================================*/

create table Layercake.schema_migration
(
    migration_id  nvarchar(200) not null
        constraint pk_schema_migration primary key clustered,
    applied_at    datetime2(3)  not null
        constraint df_schema_migration_applied_at default sysdatetime(),
    applied_by    nvarchar(20)  not null
        constraint ck_schema_migration_applied_by check (applied_by in ('run', 'baseline')),
    duration_ms   int           null,
    deployed_from nvarchar(200) null   -- host that ran the deploy, for audit
);
