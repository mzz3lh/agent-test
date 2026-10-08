/*====================================================================
    Layercake.silv_ref_lapse_reason
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

-- apuk_lapsecode resolved to a description; feeds the Lapse event subtype
-- (Resigned / Deceased / Expelled / Removed / ...). Loaded insert/update-only
-- from brnz_option_set (OptionSetName = 'apuk_lapsecode').
create table Layercake.silv_ref_lapse_reason
(
    id          int identity not null constraint pk_silv_ref_lapse_reason primary key,
    lapse_code  int not null,
    reason_name nvarchar(700) not null,
    constraint uq_silv_ref_lapse_reason unique (lapse_code)
);
