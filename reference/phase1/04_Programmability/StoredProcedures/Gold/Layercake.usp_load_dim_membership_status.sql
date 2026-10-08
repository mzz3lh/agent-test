/*====================================================================
    Layercake.usp_load_dim_membership_status
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    6. Layercake.dim_membership_status
    ------------------------------------------------------------------
    Practising / Retired + N/A. Lapsed is event-only and appears in no
    dimension.
====================================================================*/
create or alter procedure Layercake.usp_load_dim_membership_status
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_membership_status', @log_id output;
        begin tran;

        update d set status_name = s.status_name
        from Layercake.dim_membership_status d
        join Layercake.silv_ref_membership_status s on s.id = d.id
        where d.status_name <> s.status_name;
        set @upd = @@rowcount;

        insert into Layercake.dim_membership_status (id, status_name)
        select s.id, s.status_name
        from Layercake.silv_ref_membership_status s
        where not exists (select 1 from Layercake.dim_membership_status d where d.id = s.id);
        set @ins = @@rowcount;

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, 0;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, 0, @err;
        throw;
    end catch
end
go
