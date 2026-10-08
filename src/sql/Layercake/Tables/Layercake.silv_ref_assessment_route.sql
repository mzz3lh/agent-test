/*====================================================================
    Layercake.silv_ref_assessment_route
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.silv_ref_assessment_route
(
    id          int identity not null constraint pk_silv_ref_assessment_route primary key,
    route_code  int not null,
    route_name  nvarchar(700) not null,
    constraint uq_silv_ref_assessment_route unique (route_code)
);
