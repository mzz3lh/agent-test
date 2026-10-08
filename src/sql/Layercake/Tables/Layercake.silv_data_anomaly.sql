/*====================================================================
    Layercake.silv_data_anomaly
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_data_anomaly
--  Rows where the data does not match the agreed rules. Re-derived every
--  silver run; synced on anomaly_nk (type + contact_no). Never hard-
--  deleted: a row that stops being detected is stamped resolved_at, and
--  re-opened (resolved_at cleared) if it recurs.
--
--  Most types record where the derivation had to TOLERATE bad data - the
--  contact still counts. NO_RICS_RECORD and NO_TRANSACTIONS are the
--  exceptions: each records a contact the silv_member_base driver
--  REMOVED (no membership record behind it / no transaction history at
--  all), so they are both the audit trail for the exclusion and the
--  lists fed back to the client. NO_TRANSACTIONS is raised only where
--  the removed contact had a valid enrolment or election - the removal
--  contradicts something, which is what makes it worth reporting.
--  JOIN_NO_PAYMENT is the third exclusion type: the contact stays in
--  the base, but has no paid invoice position in
--  Subs.vwSubsMemberStatuses in any campaign year, so module 9 withholds
--  its Join event and no state range opens on the enrolment / election
--  date.
--  ENROLMENT_AFTER_FIRST_PAID records a CORRECTION rather than an
--  exclusion: the recorded enrolment date sat in a later campaign year
--  than the contact's first paid position, so the silv_member_base
--  driver backdated it to the first paid year (keeping the recorded
--  date on the row). The Join lands where the paying started and the
--  later paid years derive as Renewals. ELECTION_AFTER_FIRST_PAID is
--  the same correction for a contact with no enrolment date, whose
--  election is the Join anchor and was backdated instead.
--  ENROLMENT_BEFORE_FIRST_PAID / ELECTION_BEFORE_FIRST_PAID are the
--  same correction in the other direction: the recorded date sat in a
--  campaign year with no paid position, earlier than the first paid
--  one, and was moved FORWARD to it - only where the recorded year is
--  inside the payment history. ELECTION_BEFORE_FIRST_PAID also covers
--  an election carried forward with an enrolment that moved past it.
----------------------------------------------------
create table Layercake.silv_data_anomaly
(
    anomaly_id        int identity not null constraint pk_silv_data_anomaly primary key,
    anomaly_nk        nvarchar(240) not null,        -- '<type>:<contact_no>'
    anomaly_type      varchar(40)   not null,
    contact_no        nvarchar(200) not null,
    source_enr_id     uniqueidentifier null,         -- offending enrolment row, where one exists
    detail            nvarchar(400) null,
    first_detected_at datetime2(3)  not null constraint df_silv_data_anomaly_first default sysdatetime(),
    last_seen_at      datetime2(3)  not null constraint df_silv_data_anomaly_seen  default sysdatetime(),
    resolved_at       datetime2(3)  null
);

create unique nonclustered index ux_silv_data_anomaly_nk
    on Layercake.silv_data_anomaly (anomaly_nk);

create nonclustered index ix_silv_data_anomaly_type
    on Layercake.silv_data_anomaly (anomaly_type)
    include (contact_no, resolved_at);
