/*====================================================================
    Layercake.dim_assessment_route
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_assessment_route
(
    id         int not null constraint pk_dim_assessment_route primary key,
    route_code int not null,
    route_name nvarchar(700) not null
);
go
