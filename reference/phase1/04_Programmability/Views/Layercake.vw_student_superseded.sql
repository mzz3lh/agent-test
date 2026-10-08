/*====================================================================
    Layercake.vw_student_superseded
    Silver layer - view
====================================================================*/

/*====================================================================
    STUDENTS WHO HAVE MOVED ON TO A QUALIFYING ENROLMENT
    ------------------------------------------------------------------
    One row per contact number whose Student status has been SUPERSEDED
    in the enrolment history: the most recently created Student
    application is ended, and a qualifying enrolment or election row
    (Layercake.vw_enrolment_base) was created on or after it.

    WHY IT EXISTS. The silv_member_base driver excludes a contact whose
    latest rics record carries the Student grade (200000003, 'Rules to
    note' #2). Reconciliation found contacts where that grade is STALE:
    the Student enrolment was closed and an APC / Associate enrolment
    opened - typically on the same day, minutes apart - but the rics
    record (and CE.vwContact.MemberGrade_Description) still says
    Student. Those contacts are members by every other reading, so the
    grade alone must not remove them. This view names the cohort; the
    driver keeps a contact in it despite the grade.

    THE TEST, per contact:
      1. the Student application-type row created LAST - [Created
         DateTime] then [ENR ID], never [Created Date] or [Enrolment
         Date]: the Student row and its replacement are routinely
         created on the same day, so only the datetime orders them;
      2. that row has an [End Date] - the student period is over;
      3. at least one vw_enrolment_base row (a valid enrolment or an
         election, under the full rules there) was created at or after
         the Student row's [Created DateTime]. A Student row is never in
         vw_enrolment_base - both parts exclude the type - so the
         superseding row is always a different application.
    A Student row created AFTER the qualifying one blocks the override
    (it is the row step 1 picks, and nothing follows it), so a member
    who has gone back to being a student stays excluded. A Student row
    that is still open never overrides, whatever else exists.

    Nothing about payments is tested here: an overridden contact still
    has to hold a paid position to receive a Join (module 9), exactly
    like any other member-base row.

    Shared, like vw_enrolment_base, because the same test is applied
    by the driver (usp_load_silv_member_base), by rule 6 of
    usp_load_silv_data_anomaly, and by the reconciliation scripts under
    Scripts/Reconciliation - one definition, so they cannot drift. A
    view, not a function, for the reason given on vw_enrolment_base.
====================================================================*/
create or alter view Layercake.vw_student_superseded
as
    select
        s.[Contact No],
        s.[ENR ID]                  as student_enr_id,
        s.[Created DateTime]        as student_created,
        cast(s.[End Date] as date)  as student_end_date,
        q.[ENR ID]                  as superseding_enr_id,
        q.[Created DateTime]        as superseding_created
    from (
        -- 1. the most recently created Student application per contact
        select
            e.[Contact No],
            e.[ENR ID],
            e.[Created DateTime],
            e.[End Date],
            row_number() over (partition by e.[Contact No]
                               order by e.[Created DateTime] desc, e.[ENR ID]) as n
        from Layercake.brnz_enrolment e
        where e._is_deleted = 0
          and e.[Contact No] is not null
          and e.[Application Type] = 'Student'
    ) s
    -- 3. the first qualifying row created at or after it (cross apply:
    --    no such row, no output row)
    cross apply (
        select top (1) v.[ENR ID], v.[Created DateTime]
        from Layercake.vw_enrolment_base v
        where v.[Contact No]       = s.[Contact No]
          and v.[Created DateTime] >= s.[Created DateTime]
        order by v.[Created DateTime], v.[ENR ID]
    ) q
    where s.n = 1
      -- 2. the student period is over
      and s.[End Date] is not null;
go
