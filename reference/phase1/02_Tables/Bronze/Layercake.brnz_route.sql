/*====================================================================
    Layercake.brnz_route
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

--------------------------------------------------------------
--  synapse_ce.apuk_route -> Layercake.brnz_route
--------------------------------------------------------------
create table Layercake.brnz_route
(
    apuk_routeid uniqueidentifier not null,
    apuk_name    nvarchar(200) null,
    _loaded_at   datetime2(3) not null constraint df_brnz_route_loaded  default sysdatetime(),
    _updated_at  datetime2(3) not null constraint df_brnz_route_updated default sysdatetime(),
    _is_deleted  bit not null constraint df_brnz_route_isdel default 0,
    _deleted_at  datetime2(3) null,
    constraint pk_brnz_route primary key clustered (apuk_routeid)
);
go
