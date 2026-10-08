/*====================================================================
    Layercake schema
    Security - schema

    Re-runnable: the schema is created only if it is not already there.
    CREATE SCHEMA has to be the first statement in its batch, hence the
    EXEC wrapper - the guard and the create cannot share a batch any
    other way.
====================================================================*/

if schema_id('Layercake') is null
    exec ('create schema Layercake;');
go
