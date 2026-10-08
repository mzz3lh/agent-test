/*====================================================================
    Layercake.dim_lapse_reason
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_lapse_reason
(
    id          int not null constraint pk_dim_lapse_reason primary key,
    lapse_code  int not null,
    reason_name nvarchar(700) not null
);
go
