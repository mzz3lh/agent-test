/*====================================================================
    Layercake.silv_ref_gender
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.silv_ref_gender
(
    id          int identity not null constraint pk_silv_ref_gender primary key,
    gender_code int not null,
    gender_name varchar(48) not null,
    constraint uq_silv_ref_gender unique (gender_code)
);
