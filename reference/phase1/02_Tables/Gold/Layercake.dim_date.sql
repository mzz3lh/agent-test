/*====================================================================
    Layercake.dim_date
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.dim_date  (surrogate-keyed)
--  id int identity primary key; unique index on [date]; id 0 = the
--  1900-01-01 'NA' member for fact rows whose date cannot resolve (e.g.
--  pre-spine membership events). Ids are assigned once (append-only
--  spine) and are stable thereafter - facts store date_id.
----------------------------------------------------
create table Layercake.dim_date
(
    id                 int identity not null constraint pk_dim_date primary key clustered,
    [date]             date not null,
    [campaign_year]    int not null,
    [campaign_quarter] char(2) not null
);

create unique index ix_dim_date_date on Layercake.dim_date ([date]);
go
