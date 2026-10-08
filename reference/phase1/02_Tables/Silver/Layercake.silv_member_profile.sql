/*====================================================================
    Layercake.silv_member_profile
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_member_profile
--  Per-contact reporting attributes needed by the DETAIL daily count.
--  Diff-synced so attribute changes are DETECTED - they are logged to
--  etl_daily_count_pending_rebuild rather than triggering a history
--  recompute.
----------------------------------------------------
create table Layercake.silv_member_profile
(
    contact_no      nvarchar(200) not null
        constraint pk_silv_member_profile primary key clustered,
    country_id      int  not null constraint df_silv_member_profile_ctry default 0,  -- -> silv_ref_country
    gender_id       int  not null constraint df_silv_member_profile_gen  default 0,  -- -> silv_ref_gender
    retirement_date date null                                                        -- drives day-level Practising/Retired
);
go
