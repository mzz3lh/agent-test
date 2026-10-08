/*====================================================================
    Layercake.silv_ref_membership_grade
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    3. SILVER - reference tables
    ------------------------------------------------------------------
    Identity surrogate keys, loaded insert/update-only (members are
    never deleted; names/regions are updated in place) so the ids stay
    STABLE between runs - the incremental gold facts depend on that.
    Unique natural-key constraints let the load match without touching
    the surrogate.
====================================================================*/

create table Layercake.silv_ref_membership_grade
(
    id          int identity not null constraint pk_silv_ref_membership_grade primary key,
    grade_name  varchar(24) not null,
    constraint uq_silv_ref_membership_grade unique (grade_name)
);
