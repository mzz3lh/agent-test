/*====================================================================
    Layercake.brnz_contact
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    2. BRONZE
    ------------------------------------------------------------------
    Raw 1:1 landing of each source object, plus audit / soft-delete
    columns. Rows that disappear from source are SOFT deleted
    (_is_deleted = 1); silver reads only _is_deleted = 0, so downstream
    counts reconcile 1:1 with source while history is kept.

    brnz_local_group, brnz_subs_status and brnz_option_set carry NATURAL
    keys (not identity ids) so the incremental upsert has something to
    match on. If the option set source ever carries multiple languages,
    LanguageCode must be added to that key.
====================================================================*/

------------------------------------------------
--  CE.vwContact -> Layercake.brnz_contact
------------------------------------------------
create table Layercake.brnz_contact
(
    ContactId               uniqueidentifier not null,
    Rics_contactno          nvarchar(100) null,
    Rics_ElectionDate       datetime null,
    Rics_LapsedDate         datetime null,
    MemberGrade_Description nvarchar(350) null,
    GenderCode              int null,
    rics_countryid          uniqueidentifier null,
    -- CreatedOn / StateCode land for Layercake.usp_load_ref_enrolment_exception
    -- (silver module 8a): CreatedOn is the last-resort derived date for a
    -- contact with no enrolment row carrying one, and StateCode is how the
    -- live record is preferred where a contact NUMBER holds several contact
    -- rows. Nothing else reads them - silver's own driver keys on ContactId.
    CreatedOn               datetime null,
    StateCode               int null,
    _loaded_at              datetime2(3) not null constraint df_brnz_contact_loaded  default sysdatetime(),
    _updated_at             datetime2(3) not null constraint df_brnz_contact_updated default sysdatetime(),
    _is_deleted             bit not null constraint df_brnz_contact_isdel default 0,
    _deleted_at             datetime2(3) null,
    constraint pk_brnz_contact primary key clustered (ContactId)
);
