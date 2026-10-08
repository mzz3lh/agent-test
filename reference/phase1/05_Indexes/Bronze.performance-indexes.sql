/*====================================================================
    Bronze - performance indexes
    Supporting indexes that are NOT part of any table's key design
    (those live with their table). Safe to defer until after the
    first full load, which is when they build most cheaply.

    Re-runnable: every index is dropped if present and rebuilt, so what
    ends up in the database is always what is in this file - editing a
    definition here is enough to change it on the next deploy. The cost
    is that a redeploy against a loaded database rebuilds these indexes
    rather than skipping them.
====================================================================*/

/*====================================================================
    10. PERFORMANCE INDEXES  (from 05)
    ------------------------------------------------------------------
    Shaped to the actual silver derivation queries. Filtered indexes
    mirror the silver predicates (_is_deleted = 0, approved = 1) so they
    stay small and always match.

    Not repeated here (already created with their tables above):
      * ix_contact_no_valid_from_to_grade - created in its final wide form
        with silv_member_state_ranges
      * ux_fact_annual_rate_base_segment  - part of the fact's key design
    See performance_assessment.md for the reasoning and further options.
====================================================================*/

-------------------------------- BRONZE --------------------------------

-- brnz_contact is joined on Rics_contactno by both membership-event queries
-- and the state-range build; this covers those joins without touching the
-- clustered PK (ContactId travels free as the clustering key)
drop index if exists ix_brnz_contact_contactno on Layercake.brnz_contact;
create nonclustered index ix_brnz_contact_contactno
    on Layercake.brnz_contact (Rics_contactno)
    include (Rics_ElectionDate, Rics_LapsedDate, GenderCode, rics_countryid)
    where _is_deleted = 0;
go

-- the state-range build and #mbase aggregate ALL enrolments per contact
-- ("latest record wins"), and the event queries join on contact too - one
-- covering index serves all these access patterns
drop index if exists ix_brnz_enrolment_contact on Layercake.brnz_enrolment;
create nonclustered index ix_brnz_enrolment_contact
    on Layercake.brnz_enrolment ([Contact No])
    include ([Enrolment Date], [Election Date], [Application Type], [Route ID],
             [Status Code], [State Code], [Created DateTime])
    where _is_deleted = 0;
go

-- membership events filter to a single status code before joining contacts;
-- seeking on status first avoids scanning the full enrolment history
drop index if exists ix_brnz_enrolment_status on Layercake.brnz_enrolment;
create nonclustered index ix_brnz_enrolment_status
    on Layercake.brnz_enrolment ([Status Code], [Contact No])
    include ([Enrolment Date], [Election Date], [Route ID])
    where _is_deleted = 0;
go

-- "latest rics record per membership number" partitions by membership number
-- and orders by ModifiedOn desc - this index lets that window function stream
-- without a sort
drop index if exists ix_brnz_rics_record_memno on Layercake.brnz_rics_record;
create nonclustered index ix_brnz_rics_record_memno
    on Layercake.brnz_rics_record (apuk_ricsmembershipnumber, ModifiedOn desc)
    include (apuk_contactid, apuk_lapseddate, apuk_retirementdate, apuk_lapsecode)
    where _is_deleted = 0 and apuk_ricsmembershipnumber is not null;
go

-- the payment CTE groups approved transactions by (accountnum, paymreference);
-- the filter mirrors silver's predicate exactly so the index is only as big
-- as the rows silver actually reads
drop index if exists ix_brnz_cust_trans_account on Layercake.brnz_cust_trans;
create nonclustered index ix_brnz_cust_trans_account
    on Layercake.brnz_cust_trans (accountnum, paymreference)
    include (duedate, transdate, amountcur)
    where approved = 1 and _is_deleted = 0;
go

-- the "has this contact EVER transacted" test - the driver exclusion in
-- module 8, the Readmission guard in module 9 and anomaly rule 6 in module 10
-- all run it once per contact. Deliberately NOT filtered on approved: the test
-- is the existence of a transaction, not whether it cleared, so the index above
-- cannot serve it. Key only, so it stays narrow.
drop index if exists ix_brnz_cust_trans_account_any on Layercake.brnz_cust_trans;
create nonclustered index ix_brnz_cust_trans_account_any
    on Layercake.brnz_cust_trans (accountnum)
    where _is_deleted = 0;
go
