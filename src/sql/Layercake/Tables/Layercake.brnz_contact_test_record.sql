/*====================================================================
    Layercake.brnz_contact_test_record
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

------------------------------------------------------------------------
--  ce.tblcontact_test_records -> Layercake.brnz_contact_test_record
------------------------------------------------------------------------
create table Layercake.brnz_contact_test_record
(
    contactid   uniqueidentifier not null,
    _loaded_at  datetime2(3) not null constraint df_brnz_test_rec_loaded  default sysdatetime(),
    _updated_at datetime2(3) not null constraint df_brnz_test_rec_updated default sysdatetime(),
    _is_deleted bit not null constraint df_brnz_test_rec_isdel default 0,
    _deleted_at datetime2(3) null,
    constraint pk_brnz_contact_test_record primary key clustered (contactid)
);
