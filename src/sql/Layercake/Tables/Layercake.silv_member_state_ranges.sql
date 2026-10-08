/*====================================================================
    Layercake.silv_member_state_ranges
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_member_state_ranges
--  state_seq (02 v6) persists the per-contact same-day event ordering
--  (enrolment -> election -> lapse -> readmission within a day), so
--  zero-length ranges (valid_from = valid_to) are unambiguous.
--
--  The natural-key index is created here in its FINAL form: unique, with
--  the remaining columns INCLUDEd so the stage-vs-target EXCEPT
--  comparisons in usp_load_silver read only this index (05 widens it
--  in place on existing deploys; here it is created wide from the start).
----------------------------------------------------
create table Layercake.silv_member_state_ranges
(
    id                 int identity not null constraint pk_silv_member_state_ranges primary key,
    contact_no         nvarchar(200) not null,
    valid_from         date not null,
    valid_to           date null,
    campaign_year_from int not null,
    grade              varchar(12) not null,   -- enrolment, election, lapse
    region             varchar(12) not null,
    state_seq          int null                -- same-day event ordering
);

create unique nonclustered index ix_contact_no_valid_from_to_grade
    on Layercake.silv_member_state_ranges (contact_no, valid_from, valid_to, grade)
    include (campaign_year_from, region);
