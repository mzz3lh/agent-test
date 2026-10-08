/*====================================================================
    Layercake.usp_etl_watch
    Control - ETL logging / progress
====================================================================*/

/*====================================================================
    Monitoring proc (replaces the earlier view design - no view-create
    permission needed). NOLOCK throughout is deliberate: it lets you watch
    a step whose transaction is still open, from another session.

    exec Layercake.usp_etl_watch;                      -- latest run, any layer
    exec Layercake.usp_etl_watch @layer = 'silver';    -- latest SILVER run
    exec Layercake.usp_etl_watch @run_id = '...';      -- a specific run

    Result set 1: steps (substep = null) + their sub-steps, in execution
                  order. Running steps show elapsed-so-far as duration_sec.
    Result set 2: that run's sub-steps ranked slowest-first ("where did the
                  time go?").
====================================================================*/
create or alter procedure Layercake.usp_etl_watch
    @run_id uniqueidentifier = null,
    @layer  varchar(12)      = null    -- only used to resolve the latest run when @run_id is null
as
begin
    set nocount on;

    if @run_id is null
        set @run_id = (select top (1) run_id
                       from Layercake.etl_run_log with (nolock)
                       where @layer is null or layer = @layer
                       order by log_id desc);

    /* ---- result set 1: run detail (steps + sub-steps, execution order) ---- */
    select
        v.run_id, v.log_id, v.layer, v.step_name, v.substep,
        v.started_at, v.finished_at,
        cast(v.duration_ms / 1000.0 as decimal(12,1)) as duration_sec,
        v.status, v.rows_affected,
        v.rows_inserted, v.rows_updated, v.rows_deleted, v.error_message
    from (
        select
            l.run_id, l.log_id, l.layer, l.step_name,
            cast(null as nvarchar(128))     as substep,
            l.started_at, l.finished_at,
            datediff_big(millisecond, l.started_at,
                         isnull(l.finished_at, sysdatetime())) as duration_ms,
            l.status,
            cast(null as int)               as rows_affected,
            l.rows_inserted, l.rows_updated, l.rows_deleted, l.error_message,
            cast(0 as bigint)               as sub_order
        from Layercake.etl_run_log l with (nolock)
        where l.run_id = @run_id

        union all

        select
            l.run_id, p.log_id, l.layer, l.step_name,
            p.substep,
            p.started_at, p.finished_at,
            p.duration_ms,
            'Done',
            p.rows_affected,
            null, null, null, null,
            p.progress_id                   as sub_order
        from Layercake.etl_progress_log p with (nolock)
        join Layercake.etl_run_log l with (nolock)
          on l.log_id = p.log_id
        where l.run_id = @run_id
    ) v
    order by v.log_id, v.sub_order;

    /* ---- result set 2: slowest sub-steps of this run ---- */
    select
        l.step_name, p.substep,
        cast(p.duration_ms / 1000.0 as decimal(12,1)) as duration_sec,
        p.rows_affected, p.started_at
    from Layercake.etl_progress_log p with (nolock)
    join Layercake.etl_run_log l with (nolock)
      on l.log_id = p.log_id
    where l.run_id = @run_id
    order by p.duration_ms desc;
end
go
