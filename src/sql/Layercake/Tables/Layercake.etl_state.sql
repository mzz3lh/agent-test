/*====================================================================
    Layercake.etl_state
    Control layer - table, keys and intrinsic indexes
====================================================================*/

-- generic key/date control row (02 v8). The daily-count checkpoint it used to
-- hold is superseded by etl_daily_count_loaded; the table stays for any future
-- step that wants a simple control row.
create table Layercake.etl_state
(
    state_key  nvarchar(64) not null constraint pk_etl_state primary key clustered,
    state_date date null,
    updated_at datetime2(3) not null constraint df_etl_state_updated default sysdatetime()
);
