/*====================================================================
    Layercake.dim_membership_status
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_membership_status
(
    id          int not null constraint pk_dim_membership_status primary key,
    status_name varchar(24) not null
);
go
