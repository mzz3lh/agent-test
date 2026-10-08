/*====================================================================
    Layercake.brnz_local_group
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

--------------------------------------------------------------
--  CE.vwLocalGroup -> Layercake.brnz_local_group
--  natural key: apuk_countryid (null-country rows are skipped -
--  they can never join to a contact anyway)
--------------------------------------------------------------
create table Layercake.brnz_local_group
(
    apuk_countryid          uniqueidentifier not null,
    apuk_countryid_name     nvarchar(200) null,
    market_reporting_region varchar(15) null,
    apuk_worldregionid_name nvarchar(200) null,
    _loaded_at              datetime2(3) not null constraint df_brnz_local_group_loaded  default sysdatetime(),
    _updated_at             datetime2(3) not null constraint df_brnz_local_group_updated default sysdatetime(),
    _is_deleted             bit not null constraint df_brnz_local_group_isdel default 0,
    _deleted_at             datetime2(3) null,
    constraint pk_brnz_local_group primary key clustered (apuk_countryid)
);
go
