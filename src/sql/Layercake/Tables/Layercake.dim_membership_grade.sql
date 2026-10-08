/*====================================================================
    Layercake.dim_membership_grade
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    7. GOLD - dimensions (star schema for Power BI)
    ------------------------------------------------------------------
    Dimension ids are copies of the silver reference surrogates, so they
    are stable. Gold facts carry ONLY dim surrogate keys and additive
    measures.
====================================================================*/

create table Layercake.dim_membership_grade
(
    id         int not null constraint pk_dim_membership_grade primary key,
    grade_name varchar(24) not null
);
