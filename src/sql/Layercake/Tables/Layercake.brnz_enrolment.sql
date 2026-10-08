/*====================================================================
    Layercake.brnz_enrolment
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------------
--  synapse_ce.vwEnrolments -> Layercake.brnz_enrolment
----------------------------------------------------------
create table Layercake.brnz_enrolment
(
    [ENR ID]            uniqueidentifier not null,
    [Contact No]        nvarchar(200) null,
    [Enrolment Date]    date null,
    [End Date]          date null,
    [Election Date]     date null,
    [Application Type]  nvarchar(200) null,
    [Route ID]          uniqueidentifier null,
    [Status Code]       nvarchar(20) null,
    [State Code]        int null,
    [Created Date]      date null,
    [Created DateTime]  datetime null,
    _loaded_at          datetime2(3) not null constraint df_brnz_enrolment_loaded  default sysdatetime(),
    _updated_at         datetime2(3) not null constraint df_brnz_enrolment_updated default sysdatetime(),
    _is_deleted         bit not null constraint df_brnz_enrolment_isdel default 0,
    _deleted_at         datetime2(3) null,
    constraint pk_brnz_enrolment primary key clustered ([ENR ID])
);
