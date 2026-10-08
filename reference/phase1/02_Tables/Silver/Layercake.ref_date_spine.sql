/*====================================================================
    Layercake.ref_date_spine
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    5. SILVER - configuration / spine reference tables
====================================================================*/

-- extended (insert-only) by usp_load_silver; never rebuilt
create table Layercake.ref_date_spine
(
    [date]             date not null,
    [campaign_year]    int not null,
    [campaign_quarter] char(2) not null,
    constraint pk_ref_date_spine primary key clustered ([date])
);
go
