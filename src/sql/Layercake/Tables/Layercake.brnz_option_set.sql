/*====================================================================
    Layercake.brnz_option_set
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

------------------------------------------------------------------------
--  synapse_ce.GlobalOptionSetMetadata -> Layercake.brnz_option_set
--  natural key: option set + option value
------------------------------------------------------------------------
create table Layercake.brnz_option_set
(
    OptionSetName   nvarchar(200) not null,
    EntityName      nvarchar(200) null,
    [Option]        int not null,
    LocalizedLabel  nvarchar(700) null,
    _loaded_at      datetime2(3) not null constraint df_brnz_option_set_loaded  default sysdatetime(),
    _updated_at     datetime2(3) not null constraint df_brnz_option_set_updated default sysdatetime(),
    _is_deleted     bit not null constraint df_brnz_option_set_isdel default 0,
    _deleted_at     datetime2(3) null,
    constraint pk_brnz_option_set primary key clustered (OptionSetName, [Option])
);
