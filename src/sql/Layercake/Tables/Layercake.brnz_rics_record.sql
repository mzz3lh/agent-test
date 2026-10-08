/*====================================================================
    Layercake.brnz_rics_record
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

--------------------------------------------------------------
--  synapse_ce.apuk_ricsrecord -> Layercake.brnz_rics_record
--  (apuk_membergrade folded in from 00's migration guard)
--------------------------------------------------------------
create table Layercake.brnz_rics_record
(
    Id                          uniqueidentifier not null,
    apuk_contactid              uniqueidentifier null,
    apuk_ricsmembershipnumber   nvarchar(200) null,
    apuk_lapseddate             datetime null,
    apuk_retirementdate         datetime null,
    apuk_lapsecode              int null,
    apuk_membergrade            int null,    -- landed raw; Student (200000003) exclusion lives in silver
    statecode                   int null,
    ModifiedOn                  datetime null,
    _loaded_at                  datetime2(3) not null constraint df_brnz_rics_record_loaded  default sysdatetime(),
    _updated_at                 datetime2(3) not null constraint df_brnz_rics_record_updated default sysdatetime(),
    _is_deleted                 bit not null constraint df_brnz_rics_record_isdel default 0,
    _deleted_at                 datetime2(3) null,
    constraint pk_brnz_rics_record primary key clustered (Id)
);
