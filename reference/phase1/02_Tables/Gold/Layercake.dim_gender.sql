/*====================================================================
    Layercake.dim_gender
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_gender
(
    id          int not null constraint pk_dim_gender primary key,
    gender_code int not null,
    gender_name varchar(48) not null
);
go
