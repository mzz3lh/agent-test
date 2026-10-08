/*====================================================================
    20260928_01 - brnz_contact: CreatedOn + StateCode
    ------------------------------------------------------------------
    WHAT CHANGES
      Two columns are added to Layercake.brnz_contact, and
      usp_load_brnz_contact starts landing them:
        CreatedOn  datetime null
        StateCode  int null

    WHY
      20260928_02 moves the ref_enrolment_exception capture into the
      pipeline as Layercake.usp_load_ref_enrolment_exception. That
      capture derives its dates the way the retired phase 03 seed did,
      and two of its rules read columns bronze never landed:

        * CONTACT CreatedOn is the last-resort derived date - the
          'Contact CreatedOn' / 'Contact CreatedOn (no election date)'
          sources on the exception row - for a contact with no enrolment
          row carrying a usable date. Without it that cohort cannot be
          captured at all, which is most of the difference between a
          daily load and a from-scratch rebuild.
        * StateCode is how ONE contact row is chosen where a contact
          NUMBER holds several: live record first (statecode = 0), then
          oldest CreatedOn, then ContactId. The exception table is keyed
          on contact_no, so the capture has to make that choice.

      They are landed in bronze rather than read from CE.vwContact in
      silver so the module stays inside the layering - silver reads
      bronze, and bronze is the only thing that touches source.

    OPERATOR NOTES
      * Shape plus a ONE-OFF FULL UPDATE of the table. bronze_contact is
        diff-synced on an EXCEPT over the payload, and the two new
        columns join that comparison, so the first usp_load_brnz_contact
        after this migration reports an update for every contact whose
        source CreatedOn / StateCode is not null - i.e. effectively all
        of them. That is expected once; the run after it is back to
        normal volumes.
      * Runtime: the ALTERs are metadata-only and instant. The full
        update on the next bronze load costs roughly one extra pass of
        brnz_contact (single-figure minutes on a full database).
      * No silver behaviour changes on its own. 20260928_02 is what
        starts using these columns, and it must be applied with this
        one - a deploy applies both in order.
      * Guarded per column, so the file is safe to run by hand.
====================================================================*/

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.brnz_contact')
                 and name = 'CreatedOn')
    alter table Layercake.brnz_contact
        add CreatedOn datetime null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.brnz_contact')
                 and name = 'StateCode')
    alter table Layercake.brnz_contact
        add StateCode int null;
go
