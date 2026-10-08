/*====================================================================
    Layercake.silv_ref_rpq_variant
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.silv_ref_rpq_variant
(
    id           int identity not null constraint pk_silv_ref_rpq_variant primary key,
    variant_id   uniqueidentifier not null,
    variant_name nvarchar(200) not null,
    constraint uq_silv_ref_rpq_variant unique (variant_id)
);
go
