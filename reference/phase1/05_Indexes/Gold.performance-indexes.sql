/*====================================================================
    Gold - performance indexes
    Supporting indexes that are NOT part of any table's key design
    (those live with their table). Safe to defer until after the
    first full load, which is when they build most cheaply.

    Re-runnable: every index is dropped if present and rebuilt, so what
    ends up in the database is always what is in this file - editing a
    definition here is enough to change it on the next deploy. The cost
    is that a redeploy against a loaded database rebuilds these indexes
    rather than skipping them.
====================================================================*/

--------------------------------- GOLD ---------------------------------

-- narrow date_id index on the star detail fact. The unique clustered index
-- cx_fact_daily_member_count_detail leads on date_id but carries the whole
-- row; this one-column b-tree is a fraction of the size, so the date-keyed
-- work on this fact - the per-window delete...join on date_id, the dim_date
-- joins in the window diff, the out-of-span trim, the fk_fact_daily_detail_date
-- check, and any date-only aggregation from Power BI - can seek/scan it
-- instead of the clustered index. Cheap to maintain: the load only ever
-- deletes and re-inserts whole dates.
drop index if exists ix_fact_daily_member_count_detail_date_id
    on Layercake.fact_daily_member_count_detail;
create nonclustered index ix_fact_daily_member_count_detail_date_id
    on Layercake.fact_daily_member_count_detail (date_id);
go
