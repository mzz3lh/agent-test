/*====================================================================
    Layercake.dim_rpq_variant
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_rpq_variant
(
    id           int not null constraint pk_dim_rpq_variant primary key,
    variant_id   uniqueidentifier not null,
    variant_name nvarchar(200) not null
);
go
