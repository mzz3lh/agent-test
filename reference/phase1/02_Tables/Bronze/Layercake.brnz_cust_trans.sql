/*====================================================================
    Layercake.brnz_cust_trans
    Bronze layer - table, keys and intrinsic indexes
====================================================================*/

--------------------------------------------------------------
--  synapse_fo.custtrans -> Layercake.brnz_cust_trans
--------------------------------------------------------------
create table Layercake.brnz_cust_trans
(
    recid           bigint not null,
    accountnum      nvarchar(40) null,
    duedate         datetime null,
    transdate       datetime null,
    paymreference   nvarchar(70) null,
    amountcur       numeric(32,6) null,
    approved        int null,
    _loaded_at      datetime2(3) not null constraint df_brnz_cust_trans_loaded  default sysdatetime(),
    _updated_at     datetime2(3) not null constraint df_brnz_cust_trans_updated default sysdatetime(),
    _is_deleted     bit not null constraint df_brnz_cust_trans_isdel default 0,
    _deleted_at     datetime2(3) null,
    constraint pk_brnz_cust_trans primary key clustered (recid)
);
go
