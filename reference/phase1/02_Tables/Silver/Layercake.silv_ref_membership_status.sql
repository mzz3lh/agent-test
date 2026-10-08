/*====================================================================
    Layercake.silv_ref_membership_status
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

-- Practising / Retired is a sub-status of Qualified, driven by apuk_retirementdate
create table Layercake.silv_ref_membership_status
(
    id          int identity not null constraint pk_silv_ref_membership_status primary key,
    status_name varchar(24) not null,
    constraint uq_silv_ref_membership_status unique (status_name)
);
go
